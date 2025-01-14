require 'map'

require_relative 'error'
require_relative 'pattern'
require_relative 'render'
require_relative 'context'

class Route
  attr_reader :path
  attr_reader :name
  attr_reader :site
  attr_reader :pattern

  def initialize(path, name: nil, site: nil, &block)
    @path = "#{ path }"
    @name = "#{ name }" if name
    @site = site

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
      route = self
      params = @pattern.params_for(*args)
      block = @block

      Context.new(route:, params:, &block).call
    end
  end

  def urls(&block)
    if block
      @urls = block
    else
      parse_urls(@urls)
    end
  end

  def parse_urls(urls)
    urls = (urls.respond_to?(:call) ? urls.call : urls).dup
    return [] unless urls

    urls = [urls] unless urls.is_a?(Array)

    urls.flatten!
    urls.compact!

    urls.map do |url|
      case url
        when Hash
          url_for(url)
        when String
          url.dup
        else
          raise Error.new("url=#{ url.inspect }")
      end
    end
  end
end
