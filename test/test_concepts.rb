# frozen_string_literal: true

require "test_helper"

class Conceptual
  # rubocop:disable all
  def banana_berry;end
  def banana_hammock;end
  def banana_boat;end
  def banana_bunch;end
  def address_informal_name;end
  def address_street;end
  def address_zip;end
  def formal_name_value;end
  def failure_message;end
  def failure_reason;end
  def failure_line;end
  def message;end
  def user_message;end
  def user_name;end
  # rubocop:enable all
end

class TestKleeConcepts < Minitest::Spec
  it "returns a set of concepts based upon word repetition" do
    modifiers = %w[fill_in _value has_]
    concept = Klee.object_concepts(Conceptual, modifiers: modifiers)
    assert_includes concept[4], :banana
    refute_includes concept[4], :address
    assert_includes concept[3], :address
  end
end
