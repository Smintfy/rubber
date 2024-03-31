# Content-Type is used to indicate the original media type of the resource
# (prior to any content encoding applied for sending).
class ContentType
  NONE = "none"
  TEXT_PLAIN = "text/plain"
  TEXT_HTML = "text/html"
  TEXT_CSS = "text/css"
  TEXT_JAVASCRIPT = "text/javascript"
  IMAGE_PNG = "image/png"
  IMAGE_JPEG = "image/jpeg"
  IMAGE_GIF = "image/gif"
  APPLICATION_JSON = "application/json"
  APPLICATION_XML = "application/xml"
  APPLICATION_PDF = "application/pdf"
  APPLICATION_ZIP = "application/zip"
  APPLICATION_OCTET_STREAM = "application/octet-stream"
end


# HTTP response status codes indicate whether a specific HTTP request has been successfully completed.
class ResponseCode
  OK = 200
  CREATED = 201
  BAD_REQUEST = 400
  UNAUTHORIZED = 401
  FORBIDDEN = 403
  NOT_FOUND = 404
  METHOD_NOT_ALLOWED = 405
  INTERNAL_SERVER_ERROR = 500
  NOT_IMPLEMENTED = 501
  HTTP_VERSION_NOT_SUPPORTED = 505

  def self.name(code)
    constants.find { |c| const_get(c) == code }
  end
end


# Top header includes protocol and response code
class ResponseHeader
  attr_reader :code, :version

  def initialize(code)
    @code = code
    @version = 'HTTP/1.1'
  end

  # e.g HTTP/1.1 200 OK
  def to_s
    "#{@version} #{@code} #{ResponseCode.name(@code)}"
  end
end


class ResponseBody
  attr_reader :content, :content_type

  def initialize
    @content = ""
    @content_type = ContentType::NONE
  end

  def to_s
    if @content_type == ContentType::NONE
      ""
    end
    @content
  end

  def set_content(content, content_type)
    @content = content
    @content_type = content_type
  end

  # Additional content headers based on the contents of the body
  def representation
    if @content_type == ContentType::NONE
      []
    else
      [
        "Content-Type: #{@content_type}",
        "Content-Length: #{@content.length}"
      ]
    end
  end
end


class Response
  attr_reader :header, :body

  def initialize(code)
    @header = ResponseHeader.new(code)
    @body = ResponseBody.new
  end

  # Build the response object
  def to_s
    headers = [@header.to_s] + @body.representation
    "#{headers.join("\r\n")}\r\n\r\n#{@body.to_s}"
  end

  # Send the response
  def send(conn)
    conn.send(to_s.encode, 0)
  end

  # Add content to the response, update the content type to text plain
  def set_text(text)
    @body.set_content(text, ContentType::TEXT_PLAIN)
  end

  def set_code(code)
    @header = ResponseHeader.new(code)
  end
end
