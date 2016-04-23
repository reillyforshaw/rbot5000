require 'sinatra'
require 'json'

PAGE_ACCESS_TOKEN = ENV["PAGE_ACCESS_TOKEN"]
VERIFY_TOKEN = ENV["VERIFY_TOKEN"]

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
  if params["hub.verify_token"] == VERIFY_TOKEN
    params["hub.challenge"]
  else
    "Error, wrong validation token"
  end
end

post '/webhook/?' do
  params["entry"][0]["messaging"].each do |msg|
    user_id = msg["sender"]["id"]
    message = msg["message"]["text"]

    send(user_id, message)
  end

  200
end

private def send(user_id, message)
  %x[
    curl -X POST -H "Content-Type: application/json" -d '{
      "recipient":{
        "id":#{user_id}
      },
      "message":{
        "text":"#{message}"
      }
    }' "https://graph.facebook.com/v2.6/me/messages?access_token=#{PAGE_ACCESS_TOKEN}"
  ]
end
