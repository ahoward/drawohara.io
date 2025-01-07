require 'thread'

class RateLimiter
  attr_reader :rps
  attr_reader :pad
  attr_reader :mutex
  attr_reader :timing
  attr_reader :limiting

  def initialize(rps: 8, pad: 0.042, name: 'RateLimiter', limiting: nil)
    @rps = rps.to_i
    @pad = pad.to_f
    @name = name.to_s

    @mutex = Mutex.new
    @timing = []

    @limiting = (
      limiting ||
      proc{|seconds| $stderr.puts("#{ @name }: sleep(#{ seconds })") }
    )
  end

  class Pending; end

  def limit(&block)
    size = nil
    sum = nil
    pending = Pending.new

    thread_safe do
      size = @timing.size

      if size >= @rps
        known = @timing.select{|timing| timing.is_a?(Numeric)}

        seconds =
          if known.empty?
            1.0
          else
            avg = known.sum / known.size
            total = size * avg
            seconds = [1.0 - total + @pad, 0.0].min
          end

        if seconds > 0
          @limiting[seconds]
          sleep(seconds)
        end

        @timing.clear
      else
        @timing[size] = pending
      end
    end

    a = Time.now.to_f

    block.call
  ensure
    b = Time.now.to_f
    s = b - a

    thread_safe do
      index = @timing.index(pending)

      if index
        @timing[index] = s
      end
    end
  end

  def thread_safe(&block)
    @mutex.synchronize(&block)
  end
end
