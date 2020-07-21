require "test_helper"
require 'tempfile'
require 'json'

class FastJsonparserTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::FastJsonparser::VERSION
  end

  def test_string_encoding
    result = FastJsonparser.parse('"École"')
    assert_equal Encoding::UTF_8, result.encoding
  end

  def test_symbols_encoding
    hash = FastJsonparser.parse('{"École": 1}')
    assert_includes hash, :"École"
    assert_equal Encoding::UTF_8, hash.keys.first.encoding
  end

  def test_json_load_from_file_is_working
    result = FastJsonparser.load("./benchmark/graduation.json")
    assert_equal result[:meta].length, 1
  end

  def test_json_parse_is_working
    sample_json = '{"a":"Alpha","b":true,"c":12345,"d":[true,[false,[-123456789,null],3.9676,["Something else.",false],null]],"e":{"zero":null,"one":1,"two":2,"three":[3],"four":[0,1,2,3,4]},"f":null,"h":{"a":{"b":{"c":{"d":{"e":{"f":{"g":null}}}}}}},"i":[[[[[[[null]]]]]]]}'
    result = FastJsonparser.parse(sample_json)
    assert_equal result[:a], "Alpha"
  end

  def test_file_stream_is_working
    assert_nil FastJsonparser.load_many('./benchmark/nginx_json_logs.json') {}
  end

  def test_parse_errors
    error = assert_raises FastJsonparser::ParseError do
      FastJsonparser.parse('{')
    end
    assert_equal "The JSON document has an improper structure: missing or superfluous commas, braces, missing keys, etc.", error.message

    error = assert_raises FastJsonparser::ParseError do
      FastJsonparser.parse('{"')
    end
    assert_equal "A string is opened, but never closed.", error.message
  end

  def test_load_many_batch_size
    Tempfile.create('documents') do |f|
      f.write({foo: "a" * 5_000}.to_json)
      f.close

      assert_raises FastJsonparser::BatchSizeTooSmall do
        FastJsonparser.load_many(f.path, batch_size: 1_000) {}
      end

      FastJsonparser.load_many(f.path, batch_size: 6_000) {}
    end
  end
end
