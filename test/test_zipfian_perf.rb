#!/usr/bin/env ruby

require 'rubygems'
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '../lib')
require 'zipfian'
require 'minitest/autorun'
require 'benchmark'
require 'parallelize'

class TestZipfian < MiniTest::Unit::TestCase
  def test_zipfian_performance
    cnt = 100000

    [8, 4, 2, 1].each do |thr|
      puts "# of threads: #{thr}"
      zps = Array.new(thr)
      (2..6).each do |pow|
        max = 10 ** pow

        puts "Range: 1 ~ #{max}"
        print "Initialize (sec): "
        puts Benchmark.measure {
          thr.times.peach(thr) do |idx|
            zps[idx] = Zipfian.new max, 1, true
          end
        }.real

        print "Sample throughput (op/sec): "
        puts thr * cnt / Benchmark.measure {
          thr.times.peach(thr) do |idx|
            cnt.times do |i|
              zps[idx].sample
            end
          end
        }.real
        puts
      end
      puts
    end
  end
end
