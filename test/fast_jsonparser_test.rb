require "test_helper"

class FastJsonparserTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::FastJsonparser::VERSION
  end

  def test_json_load_from_file_is_working
    result = FastJsonparser.load("./benchmark/graduation.json")
    assert_equal result["meta"].length, 1
  end

  def test_json_parse_is_working
    sample_json = '{"a":"Alpha","b":true,"c":12345,"d":[true,[false,[-123456789,null],3.9676,["Something else.",false],null]],"e":{"zero":null,"one":1,"two":2,"three":[3],"four":[0,1,2,3,4]},"f":null,"h":{"a":{"b":{"c":{"d":{"e":{"f":{"g":null}}}}}}},"i":[[[[[[[null]]]]]]]}'
    result = FastJsonparser.parse(sample_json)
    assert_equal result["a"], "Alpha"
  end
end
