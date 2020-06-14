#!/usr/bin/env ruby

require 'benchmark'
require 'json'
require './lib/fast_jsonparser/fast_jsonparser'
require 'oj'

def run_report(rep, src)
  n = 500
  rep.report("FastJsonparser") do
    n.times do
      FastJsonparser.load(src)
    end
  end
  rep.report("OJ") do
    n.times do
      Oj.load_file(src)
    end
  end
  rep.report("standard JSON") do
    n.times do
      JSON.parse(File.read(src))
    end
  end
end

Benchmark.bm do |rep|
  run_report(rep, './benchmark/graduation.json')
end

Benchmark.bm do |rep|
  run_report(rep, './benchmark/virus-info.json')
end



# graduation.json 177K
#                 user     system      total        real
# FastJsonparser  0.891831   0.037253   0.929084 (  0.931336)
# OJ              1.269141   0.045632   1.314773 (  1.317370) ~ 41% more
# standard JSON   2.338616   0.036152   2.374768 (  2.382871) ~ 155% more

# virus-info.json 1.2M
#                 user     system      total        real
# FastJsonparser  4.772700   0.321748   5.094448 (  5.100354)
# OJ              6.944966   0.267082   7.212048 (  7.253477) ~ 42% more
# standard JSON   13.311654   0.167076  13.478730 ( 13.504489) ~  164% more