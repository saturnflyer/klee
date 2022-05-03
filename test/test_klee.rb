# frozen_string_literal: true

require "test_helper"

class Something
  extend Klee
  klee_patterns do
    prefix "fill_in"
    suffix "_value"
    prefix "has_"
    middle "username"
  end

  def fill_in_formal_name
  end

  def formal_name_value
  end

  def fill_in_informal_name
  end

  def informal_name_value
  end

  def fill_in_zip
  end

  def zip_value
  end

  def fill_in_city
  end

  def fill_in_street
  end

  def enter_data
  end

  def has_error?
  end

  def has_message?
  end

  def has_weird_value
  end

  def verify_username_value
  end

  def enter_username_data
  end
end

class TestKlee < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Klee::VERSION
  end

  def test_it_does_something_useful
    gestalt = Klee[Something.new].sort
    assert_equal ["enter_data"], gestalt.unusual
  end
end
