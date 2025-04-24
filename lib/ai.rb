require 'bundler/setup'

require 'thread'
require 'json'
require 'time'
require 'securerandom'
require 'fileutils'

require 'map'
require 'anthropic'
require 'groq'
require 'mistral-ai'
require 'mistral-ai/errors'


require_relative 'rate_limiter.rb'
require_relative 'env.rb'

module AI
  def AI.provider
    AI::Groq
    #AI::Mistral
    #AI::Anthropic
    #AI::DeepSeek
  end

  def AI.completion_for(prompt, temperature:0.7, format:'txt')
    provider.completion_for(prompt, temperature:, format:)
  end

  def AI.json_parse_liberally(json)
    begin
      JSON.parse(json)
    rescue => error
      begin
        json.gsub!('```json', '')
        json.gsub!('```', '')
        JSON.parse(json)
      rescue
        raise error
      end
    end
  end

  def AI.count_tokens(*args)
    string = args.join("\n")
    words = string.scan(/\w+/)
    words_per_token = 3.0/4.0
    (words.size * 1/words_per_token).to_i
  end

  class Groq
    @@API_KEY = ENV.fetch('GROQ_API_KEY')
    @@MODEL = 'llama-3.3-70b-versatile'
    #@@MODEL = 'compound-beta'
    @@MAX_TOKENS = 128_000
    @@TIMEOUT = 420

    @@RPM = 30 #60
    @@RATE_LIMTER = RateLimiter.new(name: 'groq', rpm: @@RPM - 1)

    attr_reader :client

    def initialize(api_key: @@API_KEY, timeout: @@TIMEOUT)
      @api_key = api_key
      @timeout = timeout
      @client = ::Groq::Client.new(api_key: @api_key, model_id: @@MODEL, timeout: @timeout)
    end

    def completion_for(*args, role:'user', system:nil, prompt:nil, temperature:nil, format:nil)
      content = [prompt || args].join("\n")
      Groq.try_hard do
        Groq.rate_limit do
          client.chat(content).fetch('content')
        end
      end
    end

    def Groq.completion_for(...)
      new.completion_for(...)
    end

    def Groq.rate_limit(&block)
      @@RATE_LIMTER.limit(&block)
    end

    def Groq.try_hard(*args, &block)
      if @try_hard == false
        return block.call
      end

      n = 6
      errors = []
      fatal = [
        RangeError,
        NameError,
        ArgumentError,
        Faraday::BadRequestError,
        Faraday::ClientError
      ]

      n.times do |i|
        begin
          return block.call
        rescue => error
          raise error if fatal.include?(error.class)
          errors.push(error)
          s = (2 ** (i + 2))
          warn "Groq.try_hard: sleep(#{ s }), #{ error.class }[#{ error.message }]"
          sleep(s)
        end
      end

      raise errors.last
    end

    def Groq.try_hard=(try_hard)
      @try_hard = !!try_hard
    end
  end

  class Anthropic
    @@API_KEY = ENV.fetch('ANTHROPIC_API_KEY')
    @@MODEL = 'claude-3-5-sonnet-latest'
    @@MAX_TOKENS = 42420
    @@TIMEOUT = 420

    @@RPM = 50
    @@RATE_LIMTER = RateLimiter.new(name: 'anthropic', rpm: @@RPM - 1)

    attr_reader :client

    def initialize(api_key: @@API_KEY, timeout: @@TIMEOUT)
      @api_key = api_key
      @timeout = timeout
      @client = ::Anthropic::Client.new(access_token: @api_key, request_timeout: @timeout)
    end

    def chat_completions(parameters = {}, **kws)
      parameters = Map.for(parameters).update(kws)

      parameters.keys.each do |key|
        parameters.delete(key) if parameters[key].nil?
      end

      parameters[:model] = @@MODEL unless parameters.has_key?(:model)

      parameters[:max_tokens] = @@MAX_TOKENS unless parameters.has_key?(:max_tokens)

      Anthropic.try_hard do
        Anthropic.rate_limit do
          Map.for(client.messages(parameters:))
        end
      end
    end

    def Anthropic.completion_for(...)
      new.completion_for(...)
    end

    def completion_for(*args, role:'user', system:nil, prompt:nil, temperature:nil, format:nil)
      content = [prompt || args].join("\n")
      messages = []
      messages << {role:, content:}
      result = chat_completions(system:, messages:)
      result.get(:content, 0, :text)
    end

    def Anthropic.rate_limit(&block)
      @@RATE_LIMTER.limit(&block)
    end

    def Anthropic.try_hard(*args, &block)
      if @try_hard == false
        return block.call
      end

      n = 7
      errors = []
      fatal = [
        Faraday::BadRequestError,
        Faraday::ClientError
      ]

      n.times do |i|
        begin
          return block.call
        rescue => error
          raise error if fatal.include?(error.class)
          errors.push(error)
          s = (2 ** i)
          warn "Anthropic.try_hard: sleep(#{ s }), #{ error.class }[#{ error.message }]"
          sleep(s)
        end
      end

      raise errors.last
    end

    def Anthropic.try_hard=(try_hard)
      @try_hard = !!try_hard
    end
  end

  class DeepSeek
    @@BASE_URL = 'https://api.deepseek.com'
    @@API_KEY = ENV.fetch('DEEPSEEK_API_KEY')
    @@MODEL = 'deepseek-reasoner'
    @@TIMEOUT = 420

    def initialize(api_key: @@API_KEY, timeout: @@TIMEOUT)
      @api_key = api_key
      @timeout = timeout
    end

    def chat_completions(params = {}, **kws)
      params = Map.for(params).update(kws)
      params[:model] = @@MODEL unless params.has_key?(:model)
      params[:stream] = false unless params.has_key?(:stream)

=begin
      data = params.to_hash.to_json
      cmd = "curl https://api.deepseek.com/chat/completions -s -H 'Content-Type: application/json' -H 'Authorization: Bearer #{ @api_key }' -d '#{ data }'"
      puts cmd
      oe = `#{ cmd }`
      return Map.for(JSON.parse(oe))
=end

      uri = URI.parse('https://api.deepseek.com/chat/completions')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.path)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = 'Bearer %s' % @api_key

      request.body = params.to_json

      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        Map.for(JSON.parse(response.body))
      else
        raise "Error: #{ response.code } - #{ response.message }\n\n#{ response.body }"
      end
    end

    def DeepSeek.completion_for(...)
      result = new.completion_for(...)
    end

    def completion_for(*args, system:nil, prompt:nil, temperature:nil, format:nil)
      user = [prompt || args].join("\n")

      messages = []

      if system
        messages << {role: 'system', content: [system].join("\n")}
      end

      messages << {role: 'user', content: user}

      result = chat_completions(messages:)

      result.get(:choices, 0, :message, :content)
    end

=begin
{"id"=>"6a619c81-0ea7-4b98-8a82-2fdd886e601a",
 "object"=>"chat.completion",
 "created"=>1738471159,
 "model"=>"deepseek-reasoner",
 "choices"=>
  [{"index"=>0,
    "message"=>
     {"role"=>"assistant",
      "content"=>"Sure! Here's a light-hearted one:  \n\nWhy don’t scientists trust atoms?  \n…Because they *make up everything*!  \n\n(Atomic puns are the *element* of a good joke, right?) 😄",
      "reasoning_content"=>
       "Okay, the user asked for a joke. I need to come up with something light-hearted and appropriate. Let's see, maybe something tech-related since I'm an AI. How about a classic setup with a pun.\n\nWhy don't scientists trust atoms? Because they make up everything! That's a good one. It's simple, has a pun, and relates to science which ties into the AI theme. Let me check if there's any chance it might be offensive or not. No, atoms are a safe topic. Alright, that should work."},
    "logprobs"=>nil,
    "finish_reason"=>"stop"}],
 "usage"=>
  {"prompt_tokens"=>9,
   "completion_tokens"=>161,
   "total_tokens"=>170,
   "prompt_tokens_details"=>{"cached_tokens"=>0},
   "completion_tokens_details"=>{"reasoning_tokens"=>112},
   "prompt_cache_hit_tokens"=>0,
   "prompt_cache_miss_tokens"=>9},
 "system_fingerprint"=>"fp_7e73fd9a08"}
=end
  end

  class Mistral
    @@API_KEY = ENV.fetch('MISTRAL_API_KEY')
    @@MODEL = 'pixtral-large-latest'
    @@TIMEOUT = 420

    @@RPS = 20
    @@RATE_LIMTER = RateLimiter.new(name: 'mistral', rps: @@RPS - 1)

    attr_reader :client

    def initialize(api_key: @@API_KEY, timeout: @@TIMEOUT)
      @api_key = api_key
      @timeout = timeout
      @client = ::Mistral.new(
        credentials: { api_key: @api_key },
        options: {
          connection: { request: { timeout: @timeout } },
        }
      )
    end

    %w[
      embeddings
      chat_completions
      agent_chat_completions
    ].each do |method|
      class_eval <<-____, __FILE__, __LINE__ + 1
        def #{ method }(*args, **kws, &block)
          Mistral.try_hard do
            result =
              Mistral.rate_limit do
                client.#{ method }(*args, **kws, &block)
              end

            return Map.for(result)
          end
        end
      ____
    end

    def Mistral.completion_for(prompt, temperature:0.7, model:@@MODEL, format: 'txt')
      mistral = new

      messages =
        [
          {
            "role": "user",
            "content": [
              {
                "type": "text",
                "text": prompt.to_s,
              },
            ]
          },
        ]

      params = {
        temperature: temperature,
        model: model,
        messages: messages,
      }

      if format.to_s == 'json'
        params[:response_format] = {type: "json_object"}
      end

      result =
        case
          when model =~ /^ag:/
            mistral.agent_completions(params)
          else
            mistral.chat_completions(params)
        end

      return result.get(:choices, 0, :message, :content)
    end

    def embeddings_for(input, *inputs, model: 'mistral-embed')
      inputs =
        [input.to_s, *inputs.map(&:to_s)]

      result =
        embeddings(
          { model: model,
            input: inputs,
          }
        )

      inputs.size.times.map do |i|
        result.fetch(:data).fetch(i).fetch(:embedding)
      end
    end

    def embedding_for(input, model: 'mistral-embed')
      embeddings_for(input, model:).first
    end

    def Mistral.embeddings_for(...)
      new.embeddings_for(...)
    end

    def Mistral.embedding_for(...)
      new.embedding_for(...)
    end

    def Mistral.rate_limit(&block)
      @@RATE_LIMTER.limit(&block)
    end

    def Mistral.try_hard(*args, &block)
      if @try_hard == false
        return block.call
      end

      n = 7
      errors = []

      n.times do |i|
        begin
          return block.call
        rescue ::Mistral::Errors::RequestError, Faraday::TooManyRequestsError => error
          errors.push(error)
          s = (2 ** i)
          warn "Mistral.try_hard: sleep(#{ s }), #{ error.class }[#{ error.message }]"
          sleep(s)
        end
      end

      raise errors.last
    end

    def Mistral.try_hard=(try_hard)
      @try_hard = !!try_hard
    end
  end
end

# monkey-patch
module Mistral
  module Controllers
    class Client
      def agent_chat_completions(payload, server_sent_events: nil, &callback)
        server_sent_events = false if payload[:stream] != true
        request('v1/agents/completions', payload, server_sent_events:, &callback)
      end
    end
  end
end

  class LLama
    #completion = AI::Mistral.try_hard{ AI::Mistral.completion_for(prompt) }
    #cmd = "ollama run llama3.2 /dev/stdin"
    #stdin = prompt
    #stdout = IO.popen(cmd, 'w+'){|io| io.write(stdin); io.close_write; io.read}
    #stdout.strip
  end
