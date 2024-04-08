require "./response"


class RequestMethod
  GET = "GET"
  HEAD = "HEAD"
  POST = "POST"
  PUT = "PUT"
  DELETE = "DELETE"
  CONNECT = "CONNECT"
  OPTIONS = "OPTIONS"
end


class RequestHeader
  attr_reader :method, :path, :version

  def initialize(header)
    method, @path, @version = header.split(" ")
    @method = RequestMethod.const_get(method)
  end
end


class Request
  attr_reader :raw_data, :conn, :data, :header, :response

  def initialize(raw_data, conn)
    @conn = conn
    @raw_data = raw_data
    # split into separate lines for processing
    @data = @raw_data.split("\r\n")
    # grab the first line and parse the header
    @header = RequestHeader.new(@data.shift)
    # set up as the default response and replace if successful
    @response = Response.new(ResponseCode::INTERNAL_SERVER_ERROR)
  end

  # update the response code
  def status(code)
    @response.set_code(code)
    self
  end

  # set the response text
  def text(text)
    @response.set_text(text)
    self
  end

  def html(html)
    @response.set_html(html)
    self
  end

  # send the request
  def end
    @response.send(@conn)
  end

  # get the request path
  def path
    @header.path
  end

  # get the request method
  def method
    @header.method
  end
end
