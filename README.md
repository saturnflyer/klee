# Klee (kleː)

Find similarities and differences in object APIs by tracking patterns.

See where your objects' methods are following common patterns and where they are not.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add klee

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install klee

## Usage

### Sort methods based upon patterns
```ruby
class Something
  # define methods that might match some of the patterns
end

patterns = Klee.patterns do
  prefix("has_")
  prefix("verify_")
  infix("_in_")
  suffix("_value?")
end

gestalt = Klee[Something.new, patterns: patterns]
gestalt.trace(threshold: 6) # threshold for levenshtein distance between unusual method names
puts gestalt.plot
gestalt.trace(threshold: 9) # clear the plot and trace again
puts gestalt.plot
puts gestalt["unusual"] # unusual method names
```

### Find hidden concepts based upon word repetition
```ruby
class Something
  # define methods that have common word parts
end

concept = Klee.object_concepts(Something)

concept[4] #=> Set of words that appear at least 4 times
concept[2] #=> larger Set of words that appear at least 2 times

filtered = Klee.object_concepts(Something, modifiers: %i[fill_in_ hover_over_ _message])
filtered[4] #=> Set of concepts excluding any common modifiers
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/saturnflyer/klee. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/saturnflyer/klee/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Klee project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/saturnflyer/klee/blob/main/CODE_OF_CONDUCT.md).
