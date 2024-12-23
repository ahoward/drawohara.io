require_relative 'thread_pool.rb'

require 'securerandom'
require 'tmpdir'
require 'fileutils'

require 'roda'
require 'ro'
require 'rack/test'
require 'parallel'

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
      name = (args.first || :default)
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
  attr_reader :routes
  attr_reader :server
  attr_reader :client
  attr_reader :ro

  def initialize(*args, **kws, &block)
    @name = kws.fetch(:name){ args.shift || :default }

    @routes = []

    block.call(self) if block

    @server = Server.create(name: @name, routes: @routes)

    @client = @server.client

    @ro = Ro::Root.new('./public/ro')
  end

  def inspect
    @name.inspect
  end

#
  def route(...)
    Route.new(self, ...).tap do |route|
      @routes.push(route)
    end
  end

  def urls(&block)
    if block
      @routes.each do |route|
        route.urls.each do |url|
          block.call(url)
        end
      end
    else
      Parallel.map(@routes, in_threads: 8) do |route|
        route.urls
      end.flatten
    end
  end

  class Route
    attr_reader :site
    attr_reader :path
    attr_reader :server
    attr_reader :pattern
    attr_reader :render

    def initialize(site, path, *args, **kws, &block)
      @site = site
      @path = path
      @pattern = Pattern.new(@path)
      @server = @site.server

      block.call(self) if block

      if @render.nil?
        raise ArgumentError.new("no render specified for route #{ @path }")
      end
    end

    def params_for(values)
      @pattern.params_for(values)
    end

    class Pattern < ::Array
      attr_reader :path
      attr_reader :parts
      attr_reader :keys
      attr_reader :root

      def initialize(path)
        @path = path
        @keys = []
        @root = false

        @parts = @path.to_s.strip.scan(%r`[^/]+`)

        @parts.each do |part|
          if part.start_with?(':')
            key = part.slice(1..).to_sym
            @keys.push(key)
            push(String)
          else
            push(part)
          end
        end

        if @parts.empty? && @path == "/"
          @root = true
        end
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
      @path.inspect
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
            @urls || []
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
    def Server.create(name:, routes:, &block)
      Class.new(Server) do
        const_set(:Name, "Site::Server(#{ name.to_s })")

        def self.name
          const_get(:Name)
        end

        const_set(:Client, Rack::Test::Session.new(Rack::MockSession.new(self)))

        def self.client
          const_get(:Client)
        end

        class_eval(&block) if block

        _routes = routes

        route do |r|
          _routes.each do |_route|
            if _route.pattern.root
              r.root do
                @params = {}
                instance_exec(@params, &_route.render)
              end
            else
              r.is(*_route.pattern) do |*values|
                @params = _route.params_for(values)
                instance_exec(@params, &_route.render)
              end
            end
          end
        end
      end
    end

    plugin :render
    plugin :public
    plugin :content_for
    plugin :h
  end

#
  def get(path)
    data = client.get(path.to_s)
    raise Response::Error.new(data) unless data.ok?
    Response.new(data)
  end

  class Response < ::String
    attr_reader :data

    def initialize(data)
      @data = data
      super(data.body)
    end

    def inspect
      to_s
    end

    class Error < ::StandardError
      attr_reader :data

      def initialize(data, ...)
        @data = data
        super(...)
      end
    end
  end

#
  def build(dir: './build', clean: true, parallel: 8, quiet: false)
    site = self
    tmp = Site.tmpdir

    build = proc do |url|
      resp = client.get(url)
      file = "#{ url == '/' ? '/index' : url }.html"
      path = File.join(tmp, file)

      abort "2x url=#{ url }, path=#{ path }" if test(?e, path)
      data = resp.body
      Site.binwrite(path, data)
      $stderr.puts("#{ url } -> #{ dir }#{ file }") unless quiet
    end

    a = Time.now.to_f
    urls = site.urls
    n = urls.size

    if parallel
      Parallel.each(urls, in_processes: parallel) do |url|
        build[url]
      end
    else
      urls.each do |url|
        build[url]
      end
    end

    b = Time.now.to_f
    e = (b - a).round(2)

    if test(?d, dir)
      trash = Site.tmpdir
      FileUtils.mv(dir, trash)

      fork do
        FileUtils.rm_rf(trash)
        exit!
      end
    end

    FileUtils.mv(tmp, dir)

    $stderr.puts("---")
    $stderr.puts("#{ n } in #{ e }s")
    $stderr.puts("")

    dir
  end

  def Site.tmpdir(&block)
    uuid = SecureRandom.uuid_v7
    dir = File.join('./tmp', uuid)
    FileUtils.mkdir_p(dir)
    dir
  end

  def Site.binwrite(path, data)
    dirname = File.dirname(path)
    FileUtils.mkdir_p(dirname) unless test(?e, dirname)
    IO.binwrite(path, data)
  end
end
