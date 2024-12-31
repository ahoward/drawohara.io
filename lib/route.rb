require_relative 'render'
require_relative 'pattern'
require_relative 'context'
require_relative 'error'

class Route
  attr_reader :site
  attr_reader :path
  attr_reader :pattern

  def initialize(path, site: nil, &block)
    @path = "#{ path }"
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
      Context.new(route: self, params:, site:, &@block).call
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

  class Context
    include Render

    attr_reader :route
    attr_reader :params
    attr_reader :site
    attr_reader :exports

    def initialize(route:, params:, site:, &block)
      @route = route
      @params = params
      @site = site
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
      Route.list_of_hashes(@urls).map{|hash| url_for(hash)}
    end
  end

  def Route.list_of_hashes(obj)
    list = [
      if obj.respond_to?(:call)
        obj.call
      else
        obj
      end
    ].compact.flatten

    list.map do |item|
      if item.is_a?(Hash)
        item
      else
        {id: item.to_s}
      end
    end
  end
end
