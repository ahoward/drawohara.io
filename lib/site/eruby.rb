require 'erb'

require_relative 'html_safe'

class ERuby < ERB
  def ERuby.escape_iff_needed(content)
    if content.html_safe?
      content.to_s
    else
      ::ERB::Util.html_escape(content)
    end
  end

  def make_compiler(trim_mode)
    compiler = Class.new(ERB::Compiler)

    compiler.module_eval do
      def compile_stag(stag, out, scanner)
        case stag
        when '<%=='
          scanner.stag = stag
          add_put_cmd(out, content) if content.size > 0
          self.content = ''
        else
          super
        end
      end

      def compile_content(stag, out)
        case stag
        when '<%='
          out.push("#{@insert_cmd}(::ERuby.escape_iff_needed(#{content}))")
        when '<%=='
          out.push("#{@insert_cmd}(#{content})")
        else
          super
        end
      end

      def make_scanner(src)
        scanner = Class.new(ERB::Compiler::SimpleScanner)
        scanner.module_eval do
          def stags
            ['<%=='] + super
          end
        end
        scanner.new(src, @trim_mode, @percent)
      end
    end
    compiler.new(trim_mode)
  end
end
