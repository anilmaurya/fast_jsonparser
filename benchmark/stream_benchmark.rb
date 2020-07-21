#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'benchmark'
require 'json'
require 'fast_jsonparser'
require 'yajl'

def run_report(rep, src)
  n = 30
  rep.report("FastJsonparser") do
    n.times do
      FastJsonparser.load_many(src) {}
    end
  end
  rep.report("YAJL") do
    n.times do
      parser = Yajl::Parser.new
      parser.parse(File.new(src, 'r')) {}
    end
  end
end

Benchmark.bm do |rep|
  run_report(rep, './benchmark/nginx_json_logs.json')
end


# nginx_json_logs.json 12M
#                   user     system      total        real
# FastJsonparser  3.844446   0.141822   3.986268 (  3.884655)
# YAJL            9.699621   0.110060   9.809681 (  9.826104) ~ 150% more