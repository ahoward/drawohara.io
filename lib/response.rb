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

  def check!
    raise Error.new("#{ path_info } #=> #{ status }", data: {status:, headers:, body:}) unless ok?
    self
  end

  def ok?
    (((status.to_i / 100) * 100) == 200)
  end

  def inspect
    to_s
  end
end
