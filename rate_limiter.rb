require 'thread'
require 'json'
require 'time'
require 'securerandom'
require 'fileutils'

class RateLimiter
  BACKOFF = [0.42, 1, 2, 4, 8, 16, 32, 64]

  def initialize(name, rate: 20, interval: 60)
    @name = name
    @rate = rate
    @interval = interval
    @mutex = Mutex.new
    @state_file = "./tmp/rl/#{name}.json"
    @tokens = @rate
    @last_check = Time.now
    @backoff = BACKOFF.dup
  end

  def limit(&block)
    loop do
      @mutex.synchronize do
        load_state
        now = Time.now
        elapsed = now - @last_check
        @last_check = now
        @tokens = [@tokens + elapsed * @rate / @interval, @rate].min
      end

      if @tokens >= 1
        @mutex.synchronize do
          @tokens -= 1
          save_state
        end
        return block.call
      else
        backoff = nil
        @mutex.synchronize do
          backoff = @backoff.shift
          @backoff.push(backoff)
          save_state
        end
        sleep(backoff)
      end
    end
  end

  def load_state
    @mutex.synchronize do
      state = json_load(file)

      if %w[ tokens last_check backoff ].all?{|key| state.has_key?(key)}
        @tokens = state.fetch('tokens')
        @last_check = Time.parse(state.fetch('last_check'))
        @backoff = state.fetch('backoff')
      end
    end
  end

  def json_load(file)
    raise unless test(?s, file)
    JSON.parse(IO.binread(file))
  rescue
    current_state
  end

  def current_state
    {
      'tokens' => @tokens,
      'last_check' => @last_check,
      'backoff' => @backoff
    }
  end

  def save_state
    @mutex.synchronize do
      json_save(@state_file, current_state)
    end
  end

  def json_save(file, data)
    tmp = file + ".tmp.#{ SecureRandom.uuid_v7 }"
    FileUtils.mkdir_p(File.dirname(tmp))
    json = JSON.generate(data)
    IO.binwrite(tmp, json)
    FileUtils.mv(tmp, file)
  ensure
    FileUtils.rm_rf(tmp)
  end
end
