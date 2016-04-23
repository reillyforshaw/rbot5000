require 'uri'

class Translator
  GOOGLE_TRANSLATE_API_KEY = ENV["GOOGLE_TRANSLATE_API_KEY"]

  attr_accessor :tx_req

  def initialize(tx_req)
    self.tx_req = tx_req
  end

  def translate
    source = tx_req.source_language
    target = tx_req.target_language
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

class TranslationRequest
  attr_accessor :source_language, :target_language, :text

  def initialize(source_language, target_language, text)
    @source_language = source_language
    @target_language = target_language
    @text = text    
  end

  def self.parse(message)
    message.strip =~ /((\w+) +(\w+) *:? *(.*))/
    return nil unless $1
    
    source_language = $2.downcase
    target_language = $3.downcase
    text = $4

    return nil unless Translator.language_supported?(source_language)
    return nil unless Translator.language_supported?(target_language)

    TranslationRequest.new(source_language, target_language, text)
  end

  def ==(tx_req)
    source_language == tx_req.source_language && target_language == tx_req.target_language && text == tx_req.text
  end

  def to_s
    "<#{self.class.name} source_language=#{source_language}, target_language=#{target_language}, text=\"#{text}\">"
  end
end
