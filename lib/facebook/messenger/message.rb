module Facebook
  module Messenger
    class Message
      attr_accessor :user_id, :text
      
      def initialize(user_id, text)
        self.user_id = user_id
        self.text = text
      end

      def build_reply(text)
        Message.new(user_id, text)       
      end

      def self.parse(params)
        params["entry"][0]["messaging"].map do |p|
          Message.new(p["sender"]["id"], p["message"]["text"])
        end
      end
    end
  end
end
