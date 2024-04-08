require "socket"
require "./request"
require "./response"


MAX_BUFFER = 1024


class Rubber
  def initialize
    @routes = {}
  end

  def mount(method, path, &block)
    @routes["#{method} #{path}"] = block
  end

  def serve(port)
    socket = TCPServer.new('localhost', port)
    puts "Listening on #{port}"

    loop do
      conn = socket.accept

      begin
        data = conn.recv(MAX_BUFFER).force_encoding("UTF-8")
        request = Request.new(data, conn)

        handler = @routes["#{request.method} #{request.path}"]
        response = handler.call(request)
        response.end
      rescue StandardError
        Response.new(ResponseCode::INTERNAL_SERVER_ERROR).send(conn)
      ensure
        conn.close
      end
    end
  end
end


# def get(request)
#   case request.path
#   when "/"
#     request.status(ResponseCode::OK).end
#   when ->(path) { path.start_with?("/echo/") }
#     request.status(ResponseCode::OK).text(request.path.sub("/echo/", "")).end
#   else
#     request.status(ResponseCode::NOT_FOUND).end
#   end
# end


# PORT = 4221
# socket = TCPServer.new('localhost', PORT)
# puts "Listening on #{PORT}"


# loop do
#   conn = socket.accept

#   begin
#     data = conn.recv(MAX_BUFFER_SIZE).force_encoding("UTF-8")
#     request = Request.new(data, conn)

#     case request.method
#     when RequestMethod::GET
#       get(request)
#     else
#       Response.new(ResponseCode::METHOD_NOT_ALLOWED).send(conn)
#     end
#   rescue StandardError
#     Response.new(ResponseCode::INTERNAL_SERVER_ERROR).send(conn)
#   ensure
#     conn.close
#   end
# end
