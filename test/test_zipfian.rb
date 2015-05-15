#!/usr/bin/env ruby

require 'rubygems'
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '../lib')
require 'zipfian'
require 'minitest/autorun'
require 'test-unit'
require 'parallelize'
require 'benchmark'

# TODO: naive tests
class TestZipfian < MiniTest::Unit::TestCase
  def test_init
    assert_raises(ArgumentError) { z = Zipfian.new }

    [0.9, 0, -1].each do |n|
      assert_raises(ArgumentError) { z = Zipfian.new n, 1 }
    end

    assert_raises(ArgumentError) { z = Zipfian.new 100, 0 }
    assert_raises(ArgumentError) { z = Zipfian.new 100, -1 }
  end

  def test_s_n
    z = Zipfian.new 1000, 0.1
    assert_equal 1000, z.n
    assert_equal 0.1, z.s
  end

  def test_invalid_rank
    z = Zipfian.new 1000, 0.1

    [0.1, 0, 2000].each do |k|
      assert_raises(ArgumentError) { z.pmf k }
      assert_raises(ArgumentError) { z.cdf k }
    end
  end

  def test_pmf_cdf
    z = Zipfian.new 1000, 1

    assert_equal z.pmf(1), z.cdf(1)
    (2..1000).each do |i|
      assert z.pmf(i) < z.cdf(i)
      assert z.pmf(i) < z.pmf(i - 1)
    end
    assert_equal 1, z.cdf(1000)
  end

  def test_sample
    # cached
    3.times do
      z = Zipfian.new 100000, 1, true

      10000.times do |i|
        assert (1..100000).include?(z.sample)
      end
    end
  end

  def test_cached_initialization
    puts Benchmark.measure { Zipfian.new 10 ** 6, 0.99 }
    p Zipfian.cached
    puts Benchmark.measure { Zipfian.new 10 ** 6, 0.99, true }
    p Zipfian.cached
    puts Benchmark.measure { Zipfian.new 10 ** 6, 0.99 }
    p Zipfian.cached

    puts Benchmark.measure { Zipfian.new 10 ** 6, 0.88 }
    p Zipfian.cached
    puts Benchmark.measure { Zipfian.new 10 ** 6, 0.88 }
    p Zipfian.cached
  end

  def test_multi_threaded
    m = Mutex.new
    msgs = []
    32.times.peach(32) do |idx|
      m.synchronize { msgs << :s }
      z = Zipfian.new(10 ** 6, 0.12345, true)
      m.synchronize { msgs << :e }
    end
    puts msgs.join
  end

  def test_dist
    [0.1, 0.5, 0.75, 1].each do |s|
      puts "s = #{s}"
      max = 10 ** 6
      cnt = 10 ** 4
      hst = 20
      col = 60
      z = Zipfian.new max, s
      histogram = Array.new(hst) { 0 }
      cnt.times do
        histogram[(z.sample - 1) * hst / max] += 1
      end

      r = col.to_f / histogram.max
      puts histogram.map { |e| '*' * (e * r).to_i + " : #{e}" }
      puts
    end
  end
end
