require 'thread'
require 'json'
require 'time'
require 'securerandom'
require 'fileutils'

require 'lockfile'

class RateLimiter
  TLDR = <<~____

    a simple, durable, stateful, multi-thread and multi-process safe rate_limiter

  ____

  BACKOFF = [0.42, 1, 2, 4, 8, 16, 32, 64]

  TMP = "./tmp"

  def initialize(name: 'default', rate: 20, interval: 60, rps: nil, rpm: nil, verbose: false)
    @name = name.to_s

    @rate = rate.to_i
    @interval = interval.to_i

    if rps
      @rps = rps.to_i
      @rate = @rps
      @interval = 1
    end

    if rpm
      @rpm = rpm.to_i
      @rate = @rpm
      @interval = 60
    end

    @verbose = !!verbose

    @id = "#{@name}-#{@rate}-#{@interval}"

    @mutex = Mutex.new
    @state_file = "#{TMP}/rate_limiter/#{@id}.json"
    @lock_file = Lockfile.new(@state_file + '.lock')

    FileUtils.mkdir_p(File.dirname(@state_file))

    @tokens = @rate
    @last_check = Time.now
    @backoff = BACKOFF.dup
  end

  def limit(&block)
    loop do
      transaction do
        now = Time.now
        elapsed = now - @last_check
        @last_check = now
        @tokens = [@tokens + elapsed * @rate / @interval, @rate].min.to_i
      end

      if @tokens >= 1
        transaction do
          @tokens -= 1
        end

        return block.call
      else
        backoff = nil

        transaction do
          @backoff.push(backoff = @backoff.shift)
        end

        warn("RateLimiter[#{@id}].sleep(#{ backoff })") if @verbose

        sleep(backoff)
      end
    end
  end

  def transaction(&block)
    lock! do
      load_state!

      begin
        block.call
      ensure
        save_state!
      end
    end
  end

  def lock!(&block)
    @mutex.synchronize do
      @lock_file.lock do
        block.call
      end
    end
  end

  def load_state!
    save_state! unless test(?s, @state_file)
    state = JSON.parse(IO.binread(@state_file))

    if %w[ tokens last_check backoff ].all?{|key| state.has_key?(key)}
      @tokens = state.fetch('tokens')
      @last_check = Time.parse(state.fetch('last_check'))
      @backoff = state.fetch('backoff')
    end
  end

  def save_state!
    tmp = @state_file + ".tmp.#{ SecureRandom.uuid_v7 }"
    FileUtils.mkdir_p(File.dirname(tmp))
    json = JSON.generate(current_state)
    IO.binwrite(tmp, json)
    FileUtils.mv(tmp, @state_file)
  ensure
    FileUtils.rm_f(tmp)
  end

  def current_state
    {
      'tokens' => @tokens,
      'last_check' => @last_check.iso8601(2),
      'backoff' => @backoff
    }
  end
end
