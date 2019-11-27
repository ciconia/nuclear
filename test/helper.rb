# frozen_string_literal: true

require 'bundler/setup'

require 'minitest/autorun'
require 'minitest/reporters'

require 'polyphony'
require 'fileutils'

require_relative './eg'

::Exception.__disable_sanitized_backtrace__ = true

Minitest::Reporters.use! [
  Minitest::Reporters::SpecReporter.new
]

class MiniTest::Test
  def teardown
    # wait for reactor loop to finish running
    suspend
    Polyphony.reset!
  end
end