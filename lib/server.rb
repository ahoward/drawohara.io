require 'rack'
require 'rack/builder'
require 'stringio'
require 'json'

require_relative 'error'
require_relative 'render'
require_relative 'route'
require_relative 'response'

class Server
#
  include Render

#
  attr_reader :routes

#
  def initialize(directory: './public', &block)
    @routes = []

    if directory
      @directory = Rack::Directory.new(directory)
    end

    block.call(self) if block
  end

  def route(...)
    @routes.push(Route.new(...))
  end

#
  def call(env)
    req = Rack::Request.new(env)
    path_info = req.path_info

    status = 200
    headers = {"Content-Type" => "text/html; charset=utf-8"}
    body = []

    routed = false

    routes.each do |route|
      match = route.match(path_info)

      if match
        routed = true
        result = nil
        error = nil

        args = match.to_a.slice(1..)

        begin
          result = route.call(*args)
        rescue => e
          error = e
          status = 500
          headers = {"Content-Type" => "application/json; charset=utf-8"}
          body = [error_page_for(status:, path_info:, error:)]
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
      if @directory
        @directory.call(env).tap do |_status, _headers, _iterator|
          if _status == 200
            _body = []
            _iterator.each{|buf| _body << buf}
            return [_status, _headers, _body]
          end
        end
      end

      status = 404
      headers = {"Content-Type" => "application/json; charset=utf-8"}
      body = [error_page_for(status:, path_info:)]
    end

    return [status, headers, body]
  end

#
  def error_page_for(status:, path_info:, error: nil)
    JSON.pretty_generate(
      status:,
      path_info:,
      error: error_data_for(error:),
    )
  end

  def error_data_for(error: nil)
    return nil unless error

    data = error.respond_to?(:data) ? error.data : {}

    {
      message: error.message,
      class: error.class.name,
      data: data,
      backtrace: error.backtrace,
    }
  end

#
  def get(path_info)
    env = {
      "SCRIPT_NAME" => "",
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => path_info.to_s,
      "rack.input" => StringIO.new('')
    }

    status, headers, body = call(env)

    Response.new(path_info:, status:, headers:, body:)
  end
end
