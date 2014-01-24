require 'coveralls'
Coveralls.wear!

require 'minitest/autorun'
require 'mocha/mini_test'
require 'mobu'

class MockCookies < Hash
  attr_accessor :permanent

  def initialize
    @permanent = {}
    super
  end

  def delete(cookie, opts={})
    super cookie
  end
end
