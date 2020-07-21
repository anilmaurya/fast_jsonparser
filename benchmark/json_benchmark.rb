$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

sample_json = '{"a":"Alpha","b":true,"c":12345,"d":[true,[false,[-123456789,null],3.9676,["Something else.",false],null]],"e":{"zero":null,"one":1,"two":2,"three":[3],"four":[0,1,2,3,4]},"f":null,"h":{"a":{"b":{"c":{"d":{"e":{"f":{"g":null}}}}}}},"i":[[[[[[[null]]]]]]]}'

require 'benchmark'
require 'benchmark/memory'
require 'json'
require 'fast_jsonparser'
require 'oj'

def run_report(rep, json)
  n = 10_00_000
  rep.report("FastJsonparser") do
    n.times do
      FastJsonparser.parse(json)
    end
  end
  rep.report("OJ") do
    n.times do
      Oj.load(json)
    end
  end
  rep.report("standard JSON") do
    n.times do
      JSON.parse(json)
    end
  end
end

Benchmark.bm do |rep|
  run_report(rep, sample_json)
end

# Benchmark.memory do |rep|
#   run_report(rep, sample_json)
# end

#                 user     system      total        real
# FastJsonparser  6.732325   0.005716   6.738041 (  6.750285)
# OJ              8.029406   0.006582   8.035988 (  8.055000) ~ 19% more
# standard JSON   13.025884   0.031287  13.057171 ( 13.264931) ~ 96% more