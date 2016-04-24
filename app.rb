require 'sinatra'
require 'json'

require_relative './lib/facebook/messenger'
require_relative './lib/google/translate'

before do
  if request.content_type == "application/json"
    request.body.rewind
    params.merge!(JSON.parse(request.body.read))
  end
end

get '/' do
  "RBot 5000"
end

get '/webhook/?' do
  Facebook::Messenger::Client.new.verify(params)
end

post '/webhook/?' do
  Facebook::Messenger::Message.parse(params).each do |msg|
    begin
      tx_req = Google::Translate::Request.parse(msg.text)
      reply = msg.build_reply(Google::Translate::Client.new(tx_req).translate || "Translation failed.")
    rescue Google::Translate::Error => e
      reply = msg.build_reply(e.message)
    end

    Facebook::Messenger::Client.new.send(reply)
  end

  200
end
