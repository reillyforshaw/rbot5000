module Facebook
  module Messenger
    class Client
      PAGE_ACCESS_TOKEN = ENV["PAGE_ACCESS_TOKEN"]
      VERIFY_TOKEN = ENV["VERIFY_TOKEN"]

      def send(message)
        text = message.text.gsub(/"/, "\\\"")
        %x[
          curl -X POST -H "Content-Type: application/json" -d '{
            "recipient":{
              "id":#{message.user_id}
            },
            "message":{
              "text":"#{text}"
            }
          }' "https://graph.facebook.com/v2.6/me/messages?access_token=#{PAGE_ACCESS_TOKEN}"
        ]
      end

      def verify(params)
        if params["hub.verify_token"] == VERIFY_TOKEN
          params["hub.challenge"]
        else
          "Error, wrong validation token"
        end
      end
    end
  end
end
