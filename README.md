# Zipfian

[Zipfian distribution](http://en.wikipedia.org/wiki/Zipf's_law) implementation.

## Installation

Add this line to your application's Gemfile:

    gem 'zipfian'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zipfian

## Usage

```ruby
# 1000: Number of elements
#  1.0: Exponent
z = Zipfian.new 1000, 1.0

puts z.n    # 1000
puts z.s    # 0.1

(1..1000).each do |i|
  puts [z.pmf(i), z.cdf(i)].join ' - '
end

puts z.sample    # Integer between 1 and 1000

```

## Initialization overhead and caching

On initialization, Zipfian precalculates and stores the values of cumulative distribution function for every integer in the range.
As the number gets bigger, it will take more time and memory.

```ruby
# A workaround of memory limitation
z = Zipfian.new 1000000, 0.5

puts z.sample * 1000 - rand(1000)
```

To avoid repeated initialization when multiple `Zipfian` instances are used,
you can optionally enable thread-safe caching of precalculated data at class-level
by setting the third parameter of initializer to true.

```ruby
# Cache precalculated data
z1 = Zipfian.new 1000000, 0.5, true

# Returns immediately.
z2 = Zipfian.new 1000000, 0.5
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
