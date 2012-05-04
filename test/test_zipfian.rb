#!/usr/bin/env ruby

require 'rubygems'
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '../lib')
require 'zipfian'
require 'test-unit'

class TestZipfian < Test::Unit::TestCase
  def test_init
    assert_raise(ArgumentError) { z = Zipfian.new }

    [0.9, 0, -1].each do |n|
      assert_raise(ArgumentError) { z = Zipfian.new n, 1 }
    end

    assert_raise(ArgumentError) { z = Zipfian.new 100, 0 }
    assert_raise(ArgumentError) { z = Zipfian.new 100, -1 }
  end

  def test_s_n
    z = Zipfian.new 1000, 0.1
    assert_equal 1000, z.n
    assert_equal 0.1, z.s
  end

  def test_invalid_rank
    z = Zipfian.new 1000, 0.1

    [0.1, 0, 2000].each do |k|
      assert_raise(ArgumentError) { z.pmf k }
      assert_raise(ArgumentError) { z.cdf k }
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
    z = Zipfian.new 100, 1

    10000.times do |i|
      assert (1..100).include?(z.sample)
    end
  end
end
