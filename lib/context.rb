require_relative 'render'

class Context
  include Render

  attr_reader :route

  def initialize(route:, &block)
    @route = route
    @call = block
  end

  def call(*args, **kws, &block)
    if args.empty? && kws.empty? && block
      @call = block
    else
      instance_exec(*args, **kws, &@call)
    end
  end

  def content_for(key, content = nil, &block)
    block ||= proc { |*| content }
    content_blocks[key.to_sym] << capture_later(&block)
  end

  def content_for?(key)
    content_blocks[key.to_sym].any?
  end

  def yield_content(key, default = nil)
    return default if content_blocks[key.to_sym].empty?
    content_blocks[key.to_sym].map { |b| capture(&b) }.join
  end

  def capture(&block)
    @capture = nil
    @_erbout, _buf_was = '', @_erbout
    result = yield
    @_erbout = _buf_was
    result.strip.empty? && @capture ? @capture : result
  end

  def capture_later(&block)
    proc { |*| @capture = capture(&block) }
  end

  def content_blocks
    @content_blocks ||= Hash.new {|h,k| h[k] = [] }
  end

  def h(obj)
    case obj
      when String
        ::ERB::Util.html_escape(obj)
      else
        ::ERB::Util.html_escape(obj.inspect)
    end
  end
end
