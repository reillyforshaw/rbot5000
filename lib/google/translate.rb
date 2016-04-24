module Google
  module Translate
    class Error < StandardError; end
  end
end

require_relative './translate/client'
require_relative './translate/request'
