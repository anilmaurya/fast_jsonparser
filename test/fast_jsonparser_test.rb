# frozen_string_literal: true

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
    hash = FastJsonparser.parse('{"École": 1}', symbolize_keys: true)
    assert_includes hash, :"École"
    assert_equal Encoding::UTF_8, hash.keys.first.encoding

    hash = FastJsonparser.parse('{"École": 1}', symbolize_keys: false)
    assert_includes hash, "École"
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

  def test_string_encoding
    result = FastJsonparser.parse('"École"')
    assert_equal Encoding::UTF_8, result.encoding
    assert_equal "École", result
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

  def test_compat_forward_slash_escape
    assert_compat('"\/"', "/")
  end

  def test_compat_backward_slash_escape
    assert_compat('"\\\\"', '\\')
  end

  def test_compat_illegal_escape
    refute_compat('["Illegal backslash escape: \x15"]', ["Illegal backslash escape: x15"], :raises)
  end

  def test_compat_utf8
    assert_compat('"École"', "École")
  end

  def test_compat_NaN_and_Infinity
    assert_compat('[NaN]', :raises)
    assert_compat('[Infinity]', :raises)
    assert_compat('[-Infinity]', :raises)
  end

  def test_compat_hex_numbers
    assert_compat('[0x42]', :raises)
  end

  def test_compat_weird_keys
    assert_compat('{[1]:2}', :raises)
    assert_compat('{{1:2}:2}', :raises)
    assert_compat('{null:2}', :raises)
  end

  def test_compat_trailing_commas
    assert_compat('{1:2,}', :raises)
    assert_compat('{,,,,}', :raises)
    assert_compat('[1,]', :raises)
    assert_compat('[,,,,]', :raises)
  end

  def test_compat_trailing_comments
    assert_compat('{} // comment', :raises)
    refute_compat('{} /* comment */', {}, :raises)
    assert_compat('{1:/*comment*/2}', :raises)
    refute_compat('{"a":/*comment*/"b"}', { "a" => "b" }, :raises)
  end

  def test_compat_float_precision
    assert_compat '1.3553e142', 1.3553e142
    assert_compat '1.3553E142', 1.3553E142
  end

  def test_compat_big_floats
    assert_compat '100000000000000000000000000000000000000000.0', 100000000000000000000000000000000000000000.0
  end

  def test_compat_big_integers
    assert_compat '18446744073709551615', 18446744073709551615
    refute_compat '18446744073709551616', 18446744073709551616, :raises

    assert_compat '-9223372036854775808', -9223372036854775808
    refute_compat '-9223372036854775809', -9223372036854775809, :raises
  end

  private

  def assert_compat(source, expected)
    assert_equal expected, parse(JSON, source), "This test is invalid"
    assert_equal expected, parse(FastJsonparser, source), "#{source.inspect} is not parsed the same by JSON and FastJsonparser"
  end

  def refute_compat(source, expected, got)
    refute_equal expected, got
    assert_equal expected, parse(JSON, source)
    assert_equal got, parse(FastJsonparser, source)
  end

  def parse(parser, source)
    parser.parse(source)
  rescue => error
    :raises
  end
end
