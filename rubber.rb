require "socket"
require "./request"
require "./response"


class Rubber
  def initialize
    @routes = {}
  end

  def get(path, &block)
    @routes["GET #{path}"] = block
  end

  def start(port)
    socket = TCPServer.new('localhost', port)
    puts "Listening on #{port}"

    loop do
      conn = socket.accept

      begin
        data = conn.recv(1024).force_encoding("UTF-8")
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


app = Rubber.new

app.get "/" do |request|
  request.status(ResponseCode::OK).text("Hello, world!")
end

app.start(3000)
