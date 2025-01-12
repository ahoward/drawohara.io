require 'map'

require_relative 'eruby'
require_relative 'html_safe'

module Render
  def render(template = nil, data: {}, binding: Kernel.binding, context: nil, layout: nil, file: nil, string: nil, &block)
    if data.is_a?(Hash)
      data = Map.for(data)
    end

    template = Render.template_for(template:, file:, string:)

    erb = ERuby.new(template, trim_mode: '%<>')
    erb.filename = template.file

    result =
      if context
        binding = context ? context.instance_eval{ binding } : binding
        context.push(data:)

        begin
          erb.result(binding)
        ensure
          context.pop
        end
      else
        erb.result_with_hash(data)
      end

    content = result.to_s.strip.force_encoding('UTF-8').html_safe

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

  def Render.template_for(template: nil, file: nil, string: nil)
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

  extend Render
end
