require_relative '../lib/translate'

class TestRun
  attr_accessor :successes, :failures

  def initialize
    self.successes = 0
    self.failures = []
  end

  def assert_equal!(description, expected:, actual:)
    if expected != actual
      failures << "#{description} failed. Expected #{value_description(expected)}, got #{value_description(actual)}"
    else
      self.successes += 1
    end
  end

  def report
    puts "#{successes} success, #{failures.count} failures."
    failures.each do |f|
      puts "  #{f}"
    end
  end

  private def value_description(value)
    if value || value == false
      value.to_s
    else
      "nil"
    end
  end
end

t = TestRun.new

tx_req = TranslationRequest.parse("en fr: The black cat")
t.assert_equal!("Standard with colon", expected: TranslationRequest.new("en", "fr", "The black cat"), actual: tx_req)

tx_req = TranslationRequest.parse("en fr The black cat")
t.assert_equal!("Standard without colon", expected: TranslationRequest.new("en", "fr", "The black cat"), actual: tx_req)

tx_req = TranslationRequest.parse(" en  fr   :  The black cat  ")
t.assert_equal!("Lots of spaces with colon", expected: TranslationRequest.new("en", "fr", "The black cat"), actual: tx_req)

tx_req = TranslationRequest.parse(" en  fr     The black cat  ")
t.assert_equal!("Lots of spaces without colon", expected: TranslationRequest.new("en", "fr", "The black cat"), actual: tx_req)

tx_req = TranslationRequest.parse("en dog: The black cat")
t.assert_equal!("Unsupported source language", expected: nil, actual: tx_req)

tx_req = TranslationRequest.parse("dog fr: The black cat")
t.assert_equal!("Unsupported target language", expected: nil, actual: tx_req)

tx_req = TranslationRequest.parse("Garbage")
t.assert_equal!("Total garbage", expected: nil, actual: tx_req)

t.report