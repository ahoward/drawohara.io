require_relative 'render'
require_relative 'pattern'
require_relative 'context'
require_relative 'error'

class Route
  attr_reader :path
  attr_reader :name
  attr_reader :site
  attr_reader :pattern

  def initialize(path, name: nil, site: nil, &block)
    @path = "#{ path }"
    @name = "#{ name }" if name
    @pattern = Pattern.new(@path)

    @block = proc{ raise Error.new('did you forget a `route.call(...)`?') }

    block.call(self) if block

    if @pattern.literal?
      @urls = [@path]
    end
  end

  def inspect
    @path.inspect
  end

  def match(...)
    @pattern.match(...)
  end

  def url_for(params = {})
    @pattern.expand(params)
  end

  def call(*args, **kws, &block)
    if block
      @block = block
    else
      params = named_params_for(*args)
      Request.new(route: self, params:, &@block).call
    end
  end

  def named_params_for(*values)
    keys = @pattern.keys
    values = values.flatten

    if values.size != keys.size
      raise Error.new("arity mismatch: path=#{ @path.inspect }, values=#{ values.inspect }, keys=#{ keys.inspect }")
    end

    hash = Hash[keys.zip(values)]
    params = Map.for(hash)
  end

  class Request
    include Render

    attr_reader :route
    attr_reader :params
    attr_reader :path_info
    attr_reader :site
    attr_reader :exports

    def initialize(route:, params:, &block)
      @route = route
      @params = params

      @path_info = @route.url_for(params)
      @site = @route.site

      @block = block

      @exports = {}
    end

    def call(&block)
      @block.call(self)
    end
  end

  def urls(&block)
    if block
      @urls = block
    else
      urls = (@urls.respond_to?(:call) ? @urls.call : @urls).dup
      return [] unless urls

      urls = [urls] unless urls.is_a?(Array)

      urls.flatten!
      urls.compact!

      urls.map do |url|
        case url
          when Hash
            url_for(url)
          when String
            url
          else
            raise Error.new("url=#{ url.inspect }")
        end
      end
    end
  end
end
