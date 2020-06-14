# FastJsonparser

## Fastest Json parser for Ruby

Ruby wrapper for [simdjson](https://simdjson.org) (Parsing gigabytes of JSON per second)

Initial code imported from [simdjson_ruby](https://github.com/saka1/simdjson_ruby)

Comparison with [Oj](https://github.com/ohler55/oj) gem & JSON.parse

1. Parsing JSON from file
```
FastJsonparser.load(src) is 40% faster than Oj.load_file(src)
FastJsonparser.load(src) is 155% faster than JSON.parse(File.read(src))
```
[Benchmark result](https://github.com/anilmaurya/fast_jsonparser/blob/master/benchmark/file_benchmark.rb)

```
# virus-info.json 1.2M
#                 user     system      total        real
# FastJsonparser  4.772700   0.321748   5.094448 (  5.100354)
# OJ              6.944966   0.267082   7.212048 (  7.253477) ~ 42% more
# standard JSON   13.311654   0.167076  13.478730 ( 13.504489) ~  164% more
```

2. Parsing local JSON
```
FastJsonparser.parse(json) is 19% faster than Oj.load(json)
FastJsonparser.parse(json) is 96% faster than JSON.parse(json)
```
[Benchmark result](https://github.com/anilmaurya/fast_jsonparser/blob/master/benchmark/json_benchmark.rb)
```
#                 user     system      total        real
# FastJsonparser  6.732325   0.005716   6.738041 (  6.750285)
# OJ              8.029406   0.006582   8.035988 (  8.055000) ~ 19% more
# standard JSON   13.025884   0.031287  13.057171 ( 13.264931) ~ 96% more
```

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
