module Google
  module Translate
    class Request
      attr_accessor :source_language, :target_language, :text

      def initialize(source_language, target_language, text)
        @source_language = source_language
        @target_language = target_language
        @text = text
      end

      def self.parse(message)
        message.strip =~ /((\w+) +(\w+) *:? *(.*))/
        raise ParseError.new unless $1

        Request.new($2, $3, $4)
      end

      def ==(tx_req)
        return false if tx_req == nil
        source_language == tx_req.source_language && target_language == tx_req.target_language && text == tx_req.text
      end

      def to_s
        "<#{self.class.name} source_language=#{source_language}, target_language=#{target_language}, text=\"#{text}\">"
      end
    end

    class ParseError < Error; def initialize; super("Could not parse translation request."); end; end
  end
end
