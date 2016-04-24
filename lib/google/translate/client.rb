require 'uri'
require 'json'

module Google
  module Translate
    class Client
      GOOGLE_TRANSLATE_API_KEY = ENV["GOOGLE_TRANSLATE_API_KEY"]

      attr_accessor :tx_req

      def initialize(tx_req)
        self.tx_req = tx_req
      end

      def translate
        source = tx_req.source_language.downcase
        raise UnsupportedSourceLanguageError.new(source) unless Client.language_supported?(source)

        target = tx_req.target_language.downcase
        raise UnsupportedTargetLanguageError.new(target) unless Client.language_supported?(target)

        text = URI.escape(tx_req.text)

        tx_res = %x[
          curl -X GET "https://www.googleapis.com/language/translate/v2?key=#{GOOGLE_TRANSLATE_API_KEY}&source=#{source}&target=#{target}&q=#{text}"
        ]
        return nil unless tx_res
        
        json = JSON.parse(tx_res)
        return nil unless json

        json["data"]["translations"][0]["translatedText"]
      end

      def self.supported_languages
        ["en", "fr", "es"]
      end

      def self.language_supported?(language)
        supported_languages.include?(language)
      end
    end

    class UnsupportedSourceLanguageError < Error; def initialize(l); super("Unsupported source language \"#{l}\". Valid languages are #{Client.supported_languages}."); end; end
    class UnsupportedTargetLanguageError < Error; def initialize(l); super("Unsupported target language \"#{l}\". Valid languages are #{Client.supported_languages}."); end; end
  end
end
