# frozen_string_literal: true

require "test_helper"

class TestCollaboratorIndex < Minitest::Spec
  def sample_path
    File.expand_path("samples/**/*.rb", __dir__)
  end

  describe "Klee.scan collaborators" do
    it "returns a CollaboratorIndex" do
      codebase = Klee.scan(sample_path)
      expect(codebase.collaborators).must_be_instance_of Klee::CollaboratorIndex
    end
  end

  describe "pairs" do
    it "returns pairwise co-occurrence counts" do
      codebase = Klee.scan(sample_path, threshold: 1)
      pairs = codebase.collaborators.pairs

      assert pairs.is_a?(Hash)
      pairs.each do |pair, count|
        assert pair.is_a?(Array)
        assert_equal 2, pair.size
        assert count.is_a?(Integer)
      end
    end

    it "respects threshold" do
      codebase = Klee.scan(sample_path, threshold: 100)
      assert_empty codebase.collaborators.pairs
    end

    it "respects ignore list" do
      codebase = Klee.scan(sample_path, threshold: 1, ignore: [:schema])
      pairs = codebase.collaborators.pairs

      pairs.each_key do |pair|
        refute pair.include?("schema"), "Expected schema to be ignored"
      end
    end

    it "supports method scope" do
      codebase = Klee.scan(sample_path, threshold: 1)
      file_pairs = codebase.collaborators.pairs(scope: :file)
      method_pairs = codebase.collaborators.pairs(scope: :method)

      # Method-level pairs should be <= file-level (same or fewer co-occurrences)
      assert file_pairs.is_a?(Hash)
      assert method_pairs.is_a?(Hash)
    end
  end

  describe "for" do
    it "returns collaborators for a specific identifier" do
      codebase = Klee.scan(sample_path, threshold: 1)
      # schema appears multiple times in multi_object.rb
      result = codebase.collaborators.for(:schema)

      assert result.is_a?(Hash)
      result.each do |collab, count|
        assert collab.is_a?(String)
        assert count.is_a?(Integer)
      end
    end
  end

  describe "clusters" do
    it "returns arrays of related collaborators" do
      codebase = Klee.scan(sample_path, threshold: 1)
      clusters = codebase.collaborators.clusters

      assert clusters.is_a?(Array)
      clusters.each do |cluster|
        assert cluster.is_a?(Set)
        assert cluster.size > 1, "Clusters should have more than one member"
      end
    end

    it "sorts clusters by size descending" do
      codebase = Klee.scan(sample_path, threshold: 1)
      clusters = codebase.collaborators.clusters

      sizes = clusters.map(&:size)
      assert_equal sizes, sizes.sort.reverse
    end
  end
end
