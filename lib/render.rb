require 'map'
require_relative 'eruby'
require_relative 'html_safe'

module Render
  def render(template = nil, data: {}, binding: Kernel.binding, context: nil, layout: nil, file: nil, string: nil, &block)
    template = template_for(template:, file:, string:)

    data = Map.for(data)

    erb = ERuby.new(template, trim_mode: '%<>')
    erb.filename = template.file

    result =
      if context.respond_to?(:to_hash)
        hash = context.to_hash
        erb.result_with_hash(hash)
      else
        ctx = context ? context.instance_eval{ binding } : binding
        erb.result(ctx)
      end

    string = String(result).force_encoding('utf-8').strip

    content = string.html_safe

    if layout
      if layout.is_a?(Hash)
        kws = layout.merge(data:)
        render(**kws){ content }
      else
        template = layout
        render(template, data:){ content }
      end
    else
      content
    end
  end

  def template_for(template: nil, file: nil, string: nil)
    case
      when template
        file = template
        Template.new(IO.binread(file), file:)
      when file
        Template.new(IO.binread(file), file:)
      when string
        file = "(string: #{ string[0..42] }...)"
        Template.new(string, file:)
      else
        raise ArgumentError.new({template:, file:, string:}.inspect)
    end
  end

  class Template < ::String
    attr_reader :file

    def initialize(string, file: nil)
      super(string)
      @file = file
    end
  end
end
