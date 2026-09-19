# frozen_string_literal: true

require "test_helper"
require "samples/multi_object"

class TestCollaborators < Minitest::Spec
  it "returns a set of collaborators based upon word repetition in all code" do
    collaborators = Klee.collaborators(MultiObject)
    expect(collaborators).must_be_instance_of Klee::Collaborators
  end

  it "has a rank of objects which are references with additional processing" do
    collaborators = Klee.collaborators(MultiObject)

    expect(collaborators.rank).must_equal({
      5 => ["schema"]
    })
  end

  it "tallies every message-receiving identifier in the source file" do
    collaborators = Klee.collaborators(MultiObject)

    expect(collaborators.tally).must_equal({
      "object" => 1,
      "schema" => 5
    })
  end
end
