#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'fast_jsonparser'

Thread.abort_on_exception = true

3.times do
  Thread.new do
    loop do
      begin
        FastJsonparser.parse('{"foo": "bar"')
      rescue
      end
    end
  end
end

loop do
  sleep 1
  p `ps -o rss -p #{$$}`.chomp.split("\n").last.to_i
end
