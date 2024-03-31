require 'socket'

MAX_BUFFER_SIZE = 1024

def parse(raw)
  parsed = raw.split("\r\n")
  start_line = parsed[0].split(" ")
  path = start_line[1]
  path
end

PORT = 4221
socket = TCPServer.new('localhost', PORT)
puts "Listening on #{PORT}. Press CTRL+C to cancel."

while client = socket.accept
  data = client.recv(MAX_BUFFER_SIZE)
  puts parse(data)

  client.write("HTTP/1.1 200 OK\r\n\r\n")
  client.close
end
