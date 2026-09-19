# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"

class TestConceptIndex < Minitest::Spec
  def domain_path
    File.expand_path("samples/domain.rb", __dir__)
  end

  def index(threshold: 1)
    Klee.scan(domain_path, threshold: threshold).concepts
  end

  describe "catalog" do
    it "returns entries with class/method counts and a bias" do
      entry = index.catalog.find { |row| row.word == "intensity" }

      assert_equal 2, entry.class_count
      assert_equal 0, entry.method_count
      assert_equal :type, entry.bias
    end

    it "marks verb stems as verb even when they have no class" do
      entry = index.catalog.find { |row| row.word == "build" }

      assert entry.method_count >= 3
      assert_equal 0, entry.class_count
      assert_equal :verb, entry.bias
    end

    it "marks method-heavy nouns as gaps" do
      entry = index.catalog.find { |row| row.word == "seconds" }

      assert_equal 0, entry.class_count
      assert entry.method_count >= 8
      assert_equal :gap, entry.bias
    end
  end

  describe "gaps" do
    it "returns method-heavy nouns that are not already types" do
      gaps = index.gaps(min_methods: 5)

      assert_equal 0, gaps["seconds"][:classes]
      assert gaps["seconds"][:methods] >= 8
      assert_includes gaps["seconds"][:names], "trailing_rest_seconds"
      refute gaps.key?("build")
      refute gaps.key?("calculate")
      refute gaps.key?("extract")
    end
  end

  describe "units" do
    it "groups methods by unit suffix" do
      units = index.units

      assert_includes units["seconds"], "trailing_rest_seconds"
      assert_includes units["minutes"], "prep_minutes"
      assert_includes units["kg"], "load_kg"
      assert_includes units["m"], "warmup_distance_m"
      assert_includes units["reps"], "configured_reps"
    end
  end
end

class TestRailsProfile < Minitest::Spec
  it "scans models and lib, not views" do
    Dir.mktmpdir("klee-rails-") do |root|
      FileUtils.mkdir_p(File.join(root, "app/models"))
      FileUtils.mkdir_p(File.join(root, "app/views/pages"))
      FileUtils.mkdir_p(File.join(root, "lib"))
      File.write(File.join(root, "app/models/session.rb"), "class Session; def token; end; end\n")
      File.write(File.join(root, "lib/clock.rb"), "class Clock; def tick; end; end\n")
      File.write(File.join(root, "app/views/pages/index.rb"), "class Views::Pages::Index; def view_template; end; end\n")

      Dir.chdir(root) do
        concepts = Klee.scan(profile: :rails, threshold: 1).concepts

        assert concepts[:session][:classes].include?("Session")
        assert concepts[:clock][:classes].include?("Clock")
        refute concepts.rank.key?("views")
        refute concepts[:index][:classes].any? { |name| name.include?("Views") }
      end
    end
  end

  it "applies stopwords so function words drop out of rank" do
    path = File.expand_path("samples/domain.rb", __dir__)
    raw = Klee.scan(path, threshold: 1).concepts
    rails = Klee.scan(path, profile: :rails, threshold: 1).concepts

    assert raw.rank.key?("for")
    refute rails.rank.key?("for")
    assert rails.rank.key?("seconds")
  end

  it "rejects unknown profiles" do
    error = assert_raises(ArgumentError) { Klee.scan(profile: :python) }
    assert_match(/unknown profile/, error.message)
  end
end
