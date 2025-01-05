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
  def initialize(root: './public', &block)
    @routes = []

    @root = Rack::Files.new(root)

    block.call(self) if block
  end

  def route(...)
    @routes.push(Route.new(...))
  end

#
  def call(env)
    status, headers, body = Rack::Files.new('./public').call(env)
    if status < 400
      return [status, headers, body]
    end

    req = Rack::Request.new(env)
    path_info = req.path_info

    status = 200
    headers = {"content-type" => "text/html; charset=utf-8"}
    body = []


    routes.each do |route|
      match = route.match(path_info)

      if match
        args = match.to_a.slice(1..)

        begin
          result = route.call(*args)

          next if result == :pass

          status = 200
          headers = {}
          body = [result]
        rescue => e
          error = e

          status = 500
          headers = {"content-type" => "application/json; charset=utf-8"}
          body = [error_page_for(status:, path_info:, error:)]
        end

        return [status, headers, body]
      end
    end

    status = 404
    headers = {"content-type" => "application/json; charset=utf-8"}
    body = [error_page_for(status:, path_info:)]

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
