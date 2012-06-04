require "zipfian/version"

class Zipfian
  attr_reader :n, :s

  @@global_mutex = Mutex.new
  @@mutexes      = {}
  @@h            = {}
  @@cdf          = {}

  def initialize n, s, cache = false
    unless n > 0 && n.is_a?(Integer)
      raise ArgumentError.new("Number of elements must be a positive integer")
    end
    unless s > 0
      raise ArgumentError.new("Exponent must be a positive number")
    end

    @n   = n
    @s   = s
    sums = [0]

    compute_h = lambda { (1..@n).inject(0) { |sum, i| sums[i] = sum + 1.0 / (i ** @s) } }
    compute_cdf = lambda { (0..@n).map { |i| sums[i] / @h } }

    key = [n, s]
    mutex = nil
    if cache
      @@global_mutex.synchronize do
        mutex = @@mutexes[key] ||= Mutex.new
      end
      mutex.synchronize do
        @h   = @@h[key]   ||= compute_h.call
        @cdf = @@cdf[key] ||= compute_cdf.call
      end
    else
      @@global_mutex.synchronize do
        # Do not create mutex
        mutex = @@mutexes[key]
      end
      if mutex
        mutex.synchronize do
          @h   = @@h[key]   || compute_h.call
          @cdf = @@cdf[key] || compute_cdf.call
        end
      else
        @h   = compute_h.call
        @cdf = compute_cdf.call
      end
    end
  end

  def inspect
    {
      :N => @n,
      :s => @s
    }.inspect
  end

  def pmf k
    check_rank k
    1.0 / ((k ** @s) * @h)
  end

  def cdf k
    check_rank k
    @cdf[k]
  end

  def sample
    binary_search_index @cdf, rand
  end

  def self.cached
    ret = []
    @@global_mutex.synchronize do
      @@mutexes.keys.each do |key|
        ret << { :n => key.first, :s => key.last }
      end
    end
    ret
  end
private
  def check_rank k
    unless k.is_a?(Integer) && k >= 1 && k <= @n
      raise ArgumentError.new("Rank must be a positive integer (max: #{@n})")
    end
  end

  def binary_search_index arr, v
    l = 0
    r = arr.length - 2

    while (c = (l + r) / 2) && l < r
      if v < arr[c]
        r = c - 1
      elsif v > arr[c]
        l = c + 1
      else
        return c
      end
    end

    v < arr[c] ? c : c + 1
  end
end

