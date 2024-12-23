require 'roda'

class Site
#
  REGISTRY = {}

  def Site.registry
    REGISTRY
  end

  def Site.for(*args, **kws, &block)
    if block
      new(*args, **kws, &block).tap do |site|
        Site.registry[site.name] = site
      end
    else
      name = args.first || :default
      Site.registry.fetch(name, &block)
    end
  end

  def Site.only
    Site.registry.values.last if Site.registry.size == 1
  end

  def Site.default
    Site.only || Site.registry.fetch(:default)
  end

#
  attr_reader :name
  attr_reader :server
  attr_reader :pages

  def initialize(*args, **kws, &block)
    @name = kws.fetch(:name){ args.shift || :default }
    @pages = []

    @server = Server.create(@name)
    configure(&block) if block
    @server.freeze
  end

  def inspect
    @name.inspect
  end

  def configure(&block)
    instance_eval(&block)
  end

  def urls(&block)
    accum = []

    @pages.each do |page|
      page.urls.each do |url|
        block ? block.call(url) : accum.push(url)
      end
    end

    block ? self : accum
  end

#
  def page(...)
    Page.new(self, ...).tap do |page|
      @pages.push(page)
    end
  end

  class Page
    attr_reader :site
    attr_reader :route
    attr_reader :server
    attr_reader :pattern
    attr_reader :render

    def initialize(site, route, *args, **kws, &block)
      @site = site
      @route = route.to_s
      @pattern = Pattern.new(@route)
      @server = @site.server

      configure(&block) if block

      if @render.nil?
        raise ArgumentError.new("no render specified for page #{ @route }")
      end

      _page = self
      _site = @site
      _pattern = @pattern
      _render = @render

      server.class_eval do
        route do |r|
          r.on(*_page.pattern) do |*values|
            @params = _page.pattern.params_for(values)
            instance_exec(@params, &_page.render)
          end
        end
      end
    end

    def params_for(values)
      @pattern.params_for(values)
    end

    class Pattern < ::Array
      attr_reader :route
      attr_reader :parts
      attr_reader :keys

      def initialize(route)
        @route = route
        @keys = []

        @parts = @route.to_s.strip.scan(%r`[^/]+`)

        @parts.each do |part|
          if part.start_with?(':')
            key = part.slice(1..).to_sym
            @keys.push(key)
          else
            push(part)
            push(String)
          end
        end

        freeze
        @keys.freeze
      end

      def params_for(*values)
        Hash[@keys.zip(values.flatten)]
      end

      def expand(hash)
        replace = {}

        hash.each do |key, val|
          validate_key!(key)
          replace[":#{ key }"] = "#{ val }"
        end

        '/' << @parts.map do |part|
          replace.fetch(part){ part }
        end.join('/')
      end

      def validate_key!(key)
        @keys.detect(key.to_s.to_sym) || raise(ArgumentError.new("invalid key #{ key }"))
      end
    end

    def inspect
      @route.inspect
    end

    def configure(&block)
      instance_eval(&block)
    end

    def render(*args, &block)
      if args.empty? && block.nil?
        @render
      else
        @render = block || args
      end
    end

    def urls(*args, &block)
      if block.nil? && args.empty?
        list =
          if @urls.respond_to?(:call)
            @urls.call
          else
            @urls
          end

        accum = []

        list.each do |object|
          hash =
            if object.is_a?(Hash)
              object
            else
              {id: object.to_s}
            end

          url = url_for(hash)

          accum.push(url)
        end

        accum
      else
        @urls = block || args
      end
    end

    def url_for(hash = {})
      @pattern.expand(hash)
    end
  end

#
  class Server < Roda
    def Server.create(name, &block)
      Class.new(Server) do
        def self.name; name; end
        class_eval(&block) if block
      end
    end

    plugin :render
    plugin :public
    plugin :content_for
    plugin :h
  end

#
  def get(path)
    require 'rack/test'

    client = Rack::Test::Session.new(Rack::MockSession.new(@server))
    body = client.get(path).body

    Body.new(body)
  end

  class Body < ::String
    def inspect
      to_s
    end
  end
end
