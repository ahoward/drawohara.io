class Context
  include Render

  attr_reader :ctx
  attr_reader :route
  attr_reader :params
  attr_reader :site
  attr_reader :dato
  attr_reader :path_info
  attr_reader :exports

  def initialize(route:, params:, data: {}, &block)
    @ctx = self
    @block = block

    @route = route
    @site = @route.site
    @dato = @site.dato
    @params = params

    @path_info = @route.url_for(params)

    @exports = {}

    @renderno = 0
    @stack = [{data: Map.for(data)}]
  end

  def call(&block)
    @block.call(self)
  end

  def render(*args, **kws, &block)
    kws[:context] = self

    @renderno += 1

    if @renderno == 1
      kws[:layout] ||= site.layout
    end

    super(*args, **kws, &block)
  end

  def push(data:)
    @stack.push(data: Map.for(data))
  end

  def pop
    @stack.pop
  end

  def data
    @stack.last.fetch(:data)
  end

  def h(...)
    ::ERB::Util.html_escape(...)
  end
end
