# frozen_string_literal: true

require "test_helper"
require "tmpdir"

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

class FillInForm
  def fill_in_street
  end

  def fill_in_zip
  end

  def fill_in_city
  end

  def fill_in_name
  end
end

class TestKleeConcepts < Minitest::Spec
  it "returns a set of concepts based upon word repetition" do
    modifiers = %w[fill_in _value has_]
    concept = Klee.object_concepts(Conceptual, modifiers: modifiers)
    assert_includes concept[4], :banana
    refute_includes concept[4], :address
    assert_includes concept[3], :address
  end

  it "forwards modifiers into word splitting" do
    concept = Klee.object_concepts(FillInForm, modifiers: ["fill_in_"])

    refute_includes concept.samples.keys, "fill"
    refute_includes concept.samples.keys, "in"
    assert_includes concept.samples.keys, "street"
  end

  it "maps each concept to the methods that contain it" do
    groups = Klee.object_concepts(Conceptual)[3]

    assert_kind_of Hash, groups
    assert_equal %i[address_informal_name address_street address_zip], groups[:address]
  end

  it "strips predicate and bang suffixes from tokens" do
    concept = Klee.concepts(:empty?, :valid?, :save!)

    assert_equal({"empty" => 1, "valid" => 1, "save" => 1}, concept.samples)
  end

  it "returns zero for min and max on an empty method list" do
    concept = Klee::Concepts.new

    assert_equal 0, concept.min
    assert_equal 0, concept.max
  end
end

class TestConceptIndexWords < Minitest::Spec
  def index_for(source)
    dir = Dir.mktmpdir("klee-concepts-")
    path = File.join(dir, "sample.rb")
    File.write(path, source)
    index = Klee::ConceptIndex.new(threshold: 1)
    index.add(Klee::FileAnalyzer.new(path))
    index
  end

  it "splits acronyms in class names" do
    index = index_for("class HTTPClient; end")

    assert index[:http][:classes].include?("HTTPClient")
    assert index[:client][:classes].include?("HTTPClient")
    refute index.rank.key?("httpclient")
  end
end
