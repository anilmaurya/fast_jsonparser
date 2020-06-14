#!/usr/bin/env ruby

require 'benchmark/ips'
require 'json'
require './../fast_jsonparser'
require 'oj'

def run_report(rep, src)
  rep.report("FastJsonparser") do
    FastJsonparser.load(src)
  end
  rep.report("OJ") do
    Oj.load_file(src)
  end
  rep.report("standard JSON") do
    JSON.parse(File.read(src))
  end
end

Benchmark.ips do |rep|
  run_report(rep, './graduation.json')
end


# Warming up --------------------------------------
#       FastJsonparser    57.000  i/100ms
#                   OJ    39.000  i/100ms
#        standard JSON    20.000  i/100ms
# Calculating -------------------------------------
#       FastJsonparser    574.578  (± 2.1%) i/s -      2.907k in   5.061751s
#                   OJ    401.115  (± 1.7%) i/s -      2.028k in   5.057311s ~ 43% less
#        standard JSON    211.791  (± 1.4%) i/s -      1.060k in   5.006200s ~ 174% less