require "erb"

class View
  def initialize(template, layout: nil)
    @template  = template
    @layout    = layout
  end

  def render(variables = {})
    unless @template.nil?
      templates = [read_template(@template)]
      templates << read_template(@layout) unless @layout.nil?

      content = templates.inject(nil) do |prev, temp|
        _render(temp, variables) { prev }
      end
    end
  end

  def context
    @context ||= Context.new
  end

  def format_variables(v)
    case v
    when Binding
      h = {}
      v.eval("instance_variables").each do |k|
        h[k.to_s.sub(/^@/, '')] = v.eval("instance_variable_get(:#{k})")
      end
      h
    when Hash
      v
    else
      {}
    end
  end

  private

  def read_template(template)
    unless template.empty?
      path = ::File.expand_path("../#{template}", __FILE__)
      return ::File.read(path) if ::File.exist?(path)
    end
    template
  end

  def options
    @options ||= {
      :safe_level => nil,
      :trim_mode  => '<>-',
      :eoutvar    => '@_erbout',
    }
  end

  def _render(str, variables = {})
    opts = options

    format_variables(variables).each do |name, value|
      context.instance_variable_set("@#{name}", value)
    end

    context.instance_eval do
      # str = "<% @#{opts[:eoutvar]} = #{opts[:eoutvar]} %>\n" + str
      erb = ::ERB.new(str, *opts.values_at(:safe_level, :trim_mode, :eoutvar))
      erb.result(binding).sub(/\A\n/, '')
    end
  end

  protected

  # CommonHelpers.
  module CommonHelpers
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

    #
    def partial(path, variables: nil)
      return "" if path.nil?

      variables ||= binding if variables.nil?

      View.new(path).render(variables)
    end

    #
    def h(obj)
      case obj
      when String
        ::ERB::Util.html_escape(obj)
      else
        ::ERB::Util.html_escape(obj.inspect)
      end
    end

    private

    def capture(&block)
      @capture = nil
      @_erbout, _buf_was = '', @_erbout
      result = yield
      @_erbout = _buf_was
      result.strip.empty? && @capture ? @capture : result
    end

    private

    def capture_later(&block)
      proc { |*| @capture = capture(&block) }
    end

    def content_blocks
      @content_blocks ||= Hash.new {|h,k| h[k] = [] }
    end
  end

  class Context
    include CommonHelpers
  end
end
