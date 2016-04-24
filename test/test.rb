require_relative '../lib/google/translate'

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

  def assert_error!(description, error_type)
    begin
      yield
    rescue Exception => e
      if e.class <= error_type
        self.successes += 1
        return
      end
    end

    failures << "#{description} failed. Expected block to raise error of type #{error_type.name}, but it didn't."
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

tx_req = Google::Translate::Request.parse("en fr: The black cat")
t.assert_equal!("Standard with colon", expected: Google::Translate::Request.new("en", "fr", "The black cat"), actual: tx_req)

tx_req = Google::Translate::Request.parse("en fr The black cat")
t.assert_equal!("Standard without colon", expected: Google::Translate::Request.new("en", "fr", "The black cat"), actual: tx_req)

tx_req = Google::Translate::Request.parse(" en  fr   :  The black cat  ")
t.assert_equal!("Lots of spaces with colon", expected: Google::Translate::Request.new("en", "fr", "The black cat"), actual: tx_req)

tx_req = Google::Translate::Request.parse(" en  fr     The black cat  ")
t.assert_equal!("Lots of spaces without colon", expected: Google::Translate::Request.new("en", "fr", "The black cat"), actual: tx_req)

t.assert_error!("Total garbage", Google::Translate::ParseError) do
  Google::Translate::Request.parse("Garbage")
end

t.report