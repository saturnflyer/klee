# frozen_string_literal: true

require "test_helper"
require "tmpdir"

class TestFileAnalyzer < Minitest::Spec
  def analyze(source)
    dir = Dir.mktmpdir("klee-analyzer-")
    path = File.join(dir, "sample.rb")
    File.write(path, source)
    Klee::FileAnalyzer.new(path)
  end

  def multi_object
    Klee::FileAnalyzer.new(File.expand_path("samples/multi_object.rb", __dir__))
  end

  def sample_app
    Klee::FileAnalyzer.new(File.expand_path("mcp/fixtures/sample_app.rb", __dir__))
  end

  describe "collaborators" do
    it "counts implicit-self receivers that get messages" do
      tally = multi_object.collaborators.tally

      assert_equal 5, tally["schema"]
      assert_equal 1, tally["object"]
    end

    it "finds method-style collaborators in typical Rails-ish code" do
      names = sample_app.collaborators.uniq

      assert_includes names, "subscription"
      assert_includes names, "invoice"
      assert_includes names, "orders"
      assert_includes names, "line_items"
      assert_includes names, "billing_service"
      assert_includes names, "plan"
      refute_includes names, "status"
      refute_includes names, "started_at"
    end

    it "records each receiver in a call chain, not only the root" do
      analyzer = analyze(<<~RUBY)
        class Example
          def title
            user.account.name
          end
        end
      RUBY

      assert_equal %w[user account], analyzer.collaborators
    end

    it "treats constants that receive messages as collaborators" do
      analyzer = analyze(<<~RUBY)
        class Example
          def call
            User.find(id)
          end
        end
      RUBY

      assert_includes analyzer.collaborators, "User"
    end

    it "does not treat operator messages as collaboration" do
      analyzer = analyze(<<~RUBY)
        class Example
          def active?
            status == :active
          end

          def renewal_date
            started_at + plan.duration
          end
        end
      RUBY

      names = analyzer.collaborators
      refute_includes names, "status"
      refute_includes names, "started_at"
      assert_includes names, "plan"
    end

    it "does not treat operator method names as collaborators" do
      analyzer = analyze(<<~RUBY)
        class Example
          def call
            users[0].name
          end
        end
      RUBY

      names = analyzer.collaborators
      refute_includes names, "[]"
      assert_includes names, "users"
    end

    it "does not treat block parameters as collaborators" do
      analyzer = analyze(<<~RUBY)
        class Example
          def call
            Hash.new { |bucket, key| bucket[key] = Set.new }
            items.each { |user| user.account }
            ->(token) { token.value }
          end
        end
      RUBY

      names = analyzer.collaborators
      refute_includes names, "bucket"
      refute_includes names, "key"
      refute_includes names, "user"
      refute_includes names, "token"
      refute_includes names, "[]"
      refute_includes names, "Hash"
      refute_includes names, "Set"
      assert_includes names, "items"
    end

    it "still counts method locals used as indexed collections" do
      analyzer = analyze(<<~RUBY)
        class Example
          def call
            users = load_users
            users[0]
          end
        end
      RUBY

      assert_includes analyzer.collaborators, "users"
    end

    it "does not treat conversion and query chains as collaborators" do
      analyzer = analyze(<<~RUBY)
        class Example
          def call
            name.to_s.upcase
            company.where(active: true).includes(:plan)
            User.find(id)
          end
        end
      RUBY

      names = analyzer.collaborators
      refute_includes names, "to_s"
      refute_includes names, "where"
      refute_includes names, "includes"
      assert_includes names, "name"
      assert_includes names, "company"
      assert_includes names, "User"
    end
  end

  describe "method names" do
    it "includes attr_reader/writer/accessor names" do
      analyzer = analyze(<<~RUBY)
        class Account
          attr_accessor :address_street, :address_city
          attr_reader :user
          attr_writer :token
        end
      RUBY

      assert_includes analyzer.method_names, "address_street"
      assert_includes analyzer.method_names, "address_city"
      assert_includes analyzer.method_names, "user"
      assert_includes analyzer.method_names, "token="
    end
  end

  describe "class names" do
    it "records nested classes with their enclosing namespace" do
      analyzer = analyze(<<~RUBY)
        module Foo
          class Bar
            def baz; end
          end
        end
      RUBY

      assert_includes analyzer.class_names, "Foo"
      assert_includes analyzer.class_names, "Foo::Bar"
    end

    it "keeps compact constant paths" do
      analyzer = analyze(<<~RUBY)
        class Foo::Bar
        end
      RUBY

      assert_includes analyzer.class_names, "Foo::Bar"
    end
  end
end
