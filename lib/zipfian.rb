require "zipfian/version"

class Zipfian
  def initialize n, s
    unless n > 0 && n.is_a?(Integer)
      raise ArgumentError.new("Number of elements must be a positive integer")
    end
    unless s > 0
      raise ArgumentError.new("Exponent must be a positive number")
    end

    @n   = n
    @s   = s
    sums = [0]
    @h   = (1..@n).inject(0) { |sum, i| sums[i] = sum + 1.0 / (i ** @s) }
    @cdf = (0..@n).map { |i| sums[i] / @h }

    class << @cdf
      def binary_search_index v
        l = 0
        r = self.length - 2

        while (c = (l + r) / 2) && l < r
          if v < self[c]
            r = c - 1
          elsif v > self[c]
            l = c + 1
          else
            return c
          end
        end

        v < self[c] ? c : c + 1
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
    @cdf.binary_search_index rand
  end

private
  def check_rank k
    unless k.is_a?(Integer) && k >= 1 && k <= @n
      raise ArgumentError.new("Rank must be a positive integer (max: #{@n})")
    end
  end
end

