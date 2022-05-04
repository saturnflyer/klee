# frozen_string_literal: true

require "test_helper"

class Something
  extend Klee
  klee_patterns do
    # prefix "fill_in"
    prefix "has_"
    infix "username"
    suffix "_value"
  end

  # rubocop:disable all
  def enter_data;end
  def enter_username_data;end
  def fill_in_city;end
  def fill_in_formal_name;end
  def fill_in_informal_name;end
  def fill_in_street;end
  def fill_in_zip;end
  def formal_name_value;end
  def has_error?;end
  def has_message?;end
  def has_weird_value;end
  def informal_name_value;end
  def verify_username_value;end
  def zip_value;end
  # rubocop:enable all
end

class TestKlee < Minitest::Spec
  it "plots non-matching methods into unusual" do
    gestalt = Klee[Something.new].trace
    assert gestalt.unusual?("enter_data"), "Expected to find `enter_data' in #{gestalt.plot["unusual"]}"
  end

  describe "plotting matches" do
    def gestalt
      @gestalt ||= Klee[Something.new].trace
    end

    it "matches the prefix" do
      assert_operator gestalt.prefixes["\\Ahas_"], :>, Set.new(%w[has_error? has_message?])
    end

    it "matches the infix" do
      assert_operator gestalt.infixes[".*username.*"], :>=, Set.new(%w[enter_username_data verify_username_value])
    end

    it "matches the suffix" do
      assert_operator gestalt.suffixes["_value\\z"], :>, Set.new(%w[formal_name_value has_weird_value informal_name_value verify_username_value])
    end
  end
end
