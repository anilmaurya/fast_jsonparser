# FastJsonparser

## Fastest Json parser for Ruby

Ruby wrapper for [simdjson](https://simdjson.org) (Parsing gigabytes of JSON per second)
Initial code imported from [simdjson_ruby](https://github.com/saka1/simdjson_ruby)

Comparison with Oj gem & JSON.parse

1. Parsing JSON from file

FastJsonparser.load(src) is 40% faster than Oj.load_file(src)
FastJsonparser.load(src) is 155% faster than JSON.parse(File.read(src))

2. Parsing local JSON

FastJsonparser.parse(json) is 19% faster than Oj.load(json)
FastJsonparser.parse(json) is 96% faster than JSON.parse(json)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fast_jsonparser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fast_jsonparser

## Usage

1. Parsing JSON from file

```
FastJsonparser.load(src) # src is source path for json file

Example:

FastJsonparser.load("./benchmark/graduation.json")

```

2. Parsing local JSON

```
FastJsonparser.parse(json)

Example:

FastJsonparser.parse('{"one": 1, "two": 2}')

```

3. Raise FastJsonparser::ParseError when invalid JSON provided for parsing

```
FastJsonparser.parse("123: 1") # FastJsonparser::ParseError (parse error)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/anilmaurya/fast_jsonparser. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FastJsonparser project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/fast_jsonparser/blob/master/CODE_OF_CONDUCT.md).
