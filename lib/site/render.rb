require 'map'

require_relative 'eruby'
require_relative 'html_safe'

module Render
  def Render.html_safe(content)
    content.to_s.strip.force_encoding('UTF-8').html_safe
  end

  def render(template = nil, data: {}, front_matter: {}, binding: nil, engines: nil, context: nil, layout: nil, file: nil, string: nil, &block)
  #
    template = Render.template_for(template:, file:, string:)

    data = data.is_a?(Hash) ? Map.for(data) : data

    front_matter = Map.for(front_matter)

    binding ||= Kernel.binding

    engines ||= template.engines

  #
    content = template

  #
    if engines.include?(:md)
      parsed = FrontMatterParser::Parser.new(:md).call(content)

      front_matter.apply(parsed.front_matter)

      case
        when data.is_a?(Map)
          data.apply(front_matter)

        when data.is_a?(Hash)
          data = Map.for(data).apply(front_matter).to_hash
      end

      content = parsed.content
    end

  #
    if engines.include?(:erb)
      erb = ERuby.new(content, trim_mode: '%<>')
      erb.filename = template.filename

      content =
        if context
          binding = context ? context.instance_eval{ binding } : binding
          context.push(data:, front_matter:)

          begin
            erb.result(binding)
          ensure
            context.pop
          end
        else
          erb.result_with_hash(data)
        end
    end

  #
    if engines.include?(:md)
      content = Ro::Template.render_markdown(content) # FIXME
    end

  #
    content = Render.html_safe(content)

  #
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
        Template.new(file:template)

      when file
        Template.new(file:)

      when string
        Template.new(string:)

      else
        raise ArgumentError.new({template:, file:, string:}.inspect)
    end
  end

  class Template < ::String
    attr_reader :file
    attr_reader :filename
    attr_reader :engines

    def initialize(string: nil, file: nil)
      if string.nil? && file
        string = IO.binread(file)
      end

      super(string.to_s)

      @file = file
      @filename = file ? file : "string: #{ slice(0...42) }..."

      if @file
        @engines = Template.engines_for(@file)
      else
        @engines = [:erb]
      end
    end

    def Template.engines_for(file)
      [].tap do |engines|
        basename, exts = File.basename(file.to_s).split('.', 2)

        exts.split('.').each do |ext|
          case ext
            when 'eruby', 'erb'
              engines << :erb
            when 'md', 'markdown'
              engines << :md
          end
        end

        engines.uniq!
      end
    end
  end

  extend Render
end
