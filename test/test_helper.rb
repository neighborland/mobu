require 'test/unit'
require 'shoulda-context'
require 'mocha/setup'
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
