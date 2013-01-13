require_relative '../lib/webapp'
require 'test/unit'
require 'rack/test'

class MyAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    MongoBinner
  end

  def test_my_default
    get '/hi'
    assert_equal 'Hello world', last_response.body
  end

end