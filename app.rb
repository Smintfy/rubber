# example of using rubber

require "./rubber"

app = Rubber.new
port = 4221

app.mount "GET", "/" do |request, response|
  request.text("Hello, world!").status(ResponseCode::OK).end
end

app.serve port do
  puts "Listening on #{port}"
end
