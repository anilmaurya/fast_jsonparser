# FastJsonparser

## Fastest Json parser for Ruby

Ruby wrapper for [simdjson](https://simdjson.org) (Parsing gigabytes of JSON per second)

The simdjson library uses commonly available SIMD instructions and microparallel algorithms to parse JSON 2.5 times faster than anything else out there.

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

3. Streaming json from file
```
FastJsonparser.load_many(src) is 153% faster than Yajl::Parser.new.parse(File.new(src, 'r'))
```
[Benchmark result](https://github.com/anilmaurya/fast_jsonparser/blob/master/benchmark/stream_benchmark.rb)
```
#                   user     system      total        real
# FastJsonparser  3.844446   0.141822   3.986268 (  3.884655)
# YAJL            9.699621   0.110060   9.809681 (  9.826104) ~ 150% more
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

3. Streaming JSON from file

File with multiple json can be stream with `load_many` method

Example: logs.json with following content
```
{"time": "17/May/2015:08:05:32 +0000", "remote_ip": "93.180.71.3", "remote_user": "-"}
{"time": "17/May/2015:08:05:23 +0000", "remote_ip": "93.180.71.3", "remote_user": "-"}
{"time": "17/May/2015:08:05:24 +0000", "remote_ip": "80.91.33.133", "remote_user": "-"}
```

`load_many` accepts file_path & block as arguments
```
> FastJsonparser.load_many(file_path) { |obj| p obj[:time]}
"17/May/2015:08:05:32 +0000"
"17/May/2015:08:05:23 +0000"
"17/May/2015:08:05:24 +0000"
```
If size of json batch is greater than 1 MB then use `batch_size` option

```
FastJsonparser.load_many(f.path, batch_size: 2_000) {}
```

4. Accept optional param :symbolize_keys (default symbolize_keys: true)

If string key is expected in parsed result then use

```
FastJsonparser.parse('{"one": 1, "two": 2}', symbolize_keys: false)

```

5. Raise FastJsonparser::ParseError when invalid JSON provided for parsing

```
FastJsonparser.parse("123: 1") # FastJsonparser::ParseError (parse error)
```

### Known Incompatibilities with stdlib JSON

`FastJsonparser` behaves mostly like stdlib's `JSON`, but there are a few corner cases:

- `FastJsonparser` will use symbols for hash keys by default. You can pass `symbolize_names: false` to have strings instead like `JSON`.
- `FastJsonparser` will raise on integers outside of the 64bits range (`-9223372036854775808..18446744073709551615`), `JSON` will parse them fine.
- `FastJsonparser` will raise on invalid string escapings (`"\x15"`), `JSON` will often handle some of them.
- `FastJsonparser` will raise on `/**/` comments. `JSON` will sometimes ignore them, sometimes raise.

### Example

```
> sample_json = '{"a":"Alpha","b":true,"c":12345,"d":[true,[false,[-123456789,null],3.9676,["Something else.",false],null]],"e":{"zero":null,"one":1,"two":2,"three":[3],"four":[0,1,2,3,4]},"f":null,"h":{"a":{"b":{"c":{"d":{"e":{"f":{"g":null}}}}}}},"i":[[[[[[[null]]]]]]]}'
> FastJsonparser.parse(sample_json)
=> {:a=>"Alpha", :b=>true, :c=>12345, :d=>[true, [false, [-123456789, nil], 3.9676, ["Something else.", false], nil]], :e=>{:zero=>nil, :one=>1, :two=>2, :three=>[3], :four=>[0, 1, 2, 3, 4]}, :f=>nil, :h=>{:a=>{:b=>{:c=>{:d=>{:e=>{:f=>{:g=>nil}}}}}}}, :i=>[[[[[[[nil]]]]]]]} 
```
## Development

After checking out the repo, run `rake compile` to install dependencies. Then, run `rake test` to run the tests.

For more option, refer https://github.com/rake-compiler/rake-compiler

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/anilmaurya/fast_jsonparser. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FastJsonparser project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/anilmaurya/fast_jsonparser/blob/master/CODE_OF_CONDUCT.md).
