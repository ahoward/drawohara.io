require 'rack'
require 'erb'
require 'stringio'
require 'map'

require './html_safe.rb'

class ERuby < ERB
  def ERuby.escape_iff_needed(content)
    if content.html_safe?
      content
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


module Render
  def render(template = nil, file: nil, string: nil, params: {}, data: {}, layout: nil, &block)
    template = Render.template_for(template:, file:, string:)
    params = Render.params_for(params)
    data = Render.data_for(data)

    context = Render.context_for(template:, params:, data:)
    eruby = ERuby.new(template, trim_mode: '-')
    content = eruby.result(context.binding(&block)).html_safe

    if layout
      if layout.is_a?(Hash)
        render(**layout, params: params){ content }
      else
        render(layout, params: params){ content }
      end
    else
      content
    end
  end

  def Render.template_for(template: nil, file: nil, string: nil)
    case
      when template
        IO.binread(template)
      when file
        IO.binread(file)
      when string
        string
      else
        raise ArgumentError.new({template:, file:, string:}.inspect)
    end
  end

  def Render.data_for(...)
    Map.for(...)
  end

  def Render.params_for(...)
    Map.for(...)
  end

  def Render.context_for(...)
    Context.new(...)
  end

  class Context
    include Render

    attr_reader :template
    attr_reader :params
    attr_reader :data

    def initialize(template:, params:, data:, &block)
      @template = template
      @params = params
      @data = data
    end

    def raw(*args)
      args.join.html_safe
    end

    def binding
      super
    end
  end
end

class Server
#
  include Render

#
  attr_reader :routes

#
  def initialize(&block)
    @routes = {}
    block.call(self) if block
  end

  def route(route, &block)
    @routes[route] = block
  end

#
  def call(env)
    req = Rack::Request.new(env)
    path_info = req.path_info

    status = 200
    headers = {"Content-Type" => "text/html; charset=utf-8"}
    body = []

    routed = false

    routes.each do |pattern, block|
      if pattern.match(path_info)
        routed = true
        result = nil
        error = nil

        params = {}

        begin
          result = block.call(params)
        rescue => e
          error = e
          status = 500
          headers = {"Content-Type" => "text/plain; charset=utf-8"}
          body = ["path_info: #{ path_info }\n#{ e.message }(#{ e.class })\n\n#{ (e.backtrace || []).join(10.chr) }"]
        end

        unless error
          status = 200
          headers = {}
          body = [result]
        end
      end

      break if routed || error
    end

    if not routed
      status = 404
      headers = {"Content-Type" => "text/plain; charset=utf-8"}
      body = ["path_info: #{ path_info }"]
    end

    return [status, headers, body]
  end

#
  def get(path_info)
    env = {
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => path_info.to_s,
      "rack.input" => StringIO.new('')
    }

    status, headers, body = call(env)

    Response.new(path_info:, status:, headers:, body:)
  end

#
  class Response < ::String
    attr_reader :path_info
    attr_reader :status
    attr_reader :headers
    attr_reader :body

    def initialize(path_info:, status:, headers:, body:)
      @path_info = path_info
      @status = status
      @headers = headers
      @body = body

      super([body].join)
    end

    def ok?
      (((status.to_i / 100) * 100) == 200)
    end

    def check!
      raise Error.new("#{ path_info } : #{ status }", data: {status:, headers:, body:}) unless ok?
      self
    end

    def inspect
      to_s
    end
  end

#
  class Error < ::StandardError
    attr_reader :data

    def initialize(message, *messages, data: {})
      super([message, *messages].join(' '))
      @data = data
    end
  end
end

server =
  Server.new do |s|
    s.route('/') do
      s.render 'view.html.erb', layout: 'layout.html.erb', data: {x: '42 > &'}
    end
  end

#server.route('/'){ render 'view.html.erb', layout: 'layout.html.erb', params: {x: '42 > &'} }
#server.route('/'){ render 'view.html.erb', params: {x: '42 > &'} }

resp = server.get('/')
puts '---'
puts resp
