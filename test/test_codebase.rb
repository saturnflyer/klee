# frozen_string_literal: true

require "test_helper"

class TestCodebase < Minitest::Spec
  def sample_path
    File.expand_path("samples/**/*.rb", __dir__)
  end

  describe "Klee.scan" do
    it "returns a Codebase instance" do
      codebase = Klee.scan(sample_path)
      expect(codebase).must_be_instance_of Klee::Codebase
    end

    it "accepts multiple glob patterns" do
      codebase = Klee.scan(sample_path, "lib/**/*.rb")
      expect(codebase).must_be_instance_of Klee::Codebase
    end

    it "ignores directories and non-ruby files" do
      # lib/**/* would include directories without filtering
      codebase = Klee.scan("lib/**/*", threshold: 1)
      # Should not raise Errno::EISDIR
      codebase.concepts
    end
  end

  describe "concepts" do
    it "returns a ConceptIndex" do
      codebase = Klee.scan(sample_path)
      expect(codebase.concepts).must_be_instance_of Klee::ConceptIndex
    end

    it "finds concepts from class names" do
      codebase = Klee.scan(sample_path, threshold: 1)
      # MultiObject class should contribute "multi" and "object"
      assert codebase.concepts[:multi][:classes].any? { |c| c.include?("Multi") }
    end

    it "finds concepts from method names" do
      codebase = Klee.scan(sample_path, threshold: 1)
      # details method should contribute "details"
      assert codebase.concepts[:details][:methods].include?("details")
    end

    it "respects threshold" do
      codebase = Klee.scan(sample_path, threshold: 100)
      assert_empty codebase.concepts.rank
    end

    it "respects ignore list" do
      codebase = Klee.scan(sample_path, threshold: 1, ignore: [:object])
      refute codebase.concepts.rank.key?("object")
    end
  end

  describe "concepts.rank" do
    it "returns concepts sorted by frequency" do
      codebase = Klee.scan(sample_path, threshold: 1)
      ranked = codebase.concepts.rank

      frequencies = ranked.values.map { |locs| locs[:classes].size + locs[:methods].size }
      assert_equal frequencies, frequencies.sort.reverse
    end
  end

  describe "concepts[]" do
    it "returns locations for a specific concept" do
      codebase = Klee.scan(sample_path, threshold: 1)
      details = codebase.concepts[:details]

      assert details.key?(:classes)
      assert details.key?(:methods)
    end
  end
end
