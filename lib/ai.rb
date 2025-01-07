require 'bundler/setup'

require 'thread'
require 'timeout'

require 'map'
require 'mistral-ai'
require 'mistral-ai/errors'

require_relative 'rate_limiter.rb'

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

module AI
  def AI.completion_for(...)
    Mistral.completion_for(...)
  end

  class Mistral
    API_KEY = ENV.fetch('MISTRAL_API_KEY')
    MODEL = 'pixtral-large-latest'
    TIMEOUT = 420

    RPS = 20

    RATE_LIMTER = RateLimiter.new(rps: RPS - 1)

    def initialize(api_key: API_KEY, timeout: TIMEOUT)
      @api_key = api_key
      @timeout = timeout
    end

    def client
      ::Mistral.new(
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
          Mistral.try_hard! do
            result =
              Mistral.rate_limit do
                client.#{ method }(*args, **kws, &block)
              end

            return Map.for(result)
          end
        end
      ____
    end

    def Mistral.completion_for(prompt, temperature:0.7, model:MODEL)
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

      result =
        case
          when model =~ /^ag:/
            mistral.agent_completions(params)
          else
            mistral.chat_completions(params)
        end

      return result.get(:choices, 0, :message, :content)
    end

    def Mistral.embedding_for(prompt, model: 'mistral-embed')
      mistral = new

      inputs = [prompt].flatten.compact.map(&:to_s)

      result =
        mistral.embeddings(
          { model: model,
            input: inputs,
          }
        )

      result.fetch(:data).fetch(0).fetch(:embedding)
    end

    def Mistral.rate_limit(&block)
      RATE_LIMTER.limit(&block)
    end

    def Mistral.try_hard!(n: 6, quiet: false, timeout: nil, &block)
      errors = []

      Timeout.timeout(timeout) do
        n.to_i.times do |i|
          begin
            return block.call
          rescue ::Mistral::Errors::RequestError, Faraday::TooManyRequestsError => error
            errors.push(error)
            warn("Mistral.try_hard!(n:#{ n })\n#{ emsg(error) }") unless quiet
            warn("Mistral.try_hard!(n:#{ n })\nsleep(#{ 2 ** i })") unless quiet
            sleep(2 ** i)
          end
        end
      end

      raise errors.last
    end

    def Mistral.emsg(e)
      if e.is_a?(Exception)
        "#{ e.message } (#{ e.class.name })\n#{ Array(e.backtrace).join(10.chr) }"
      else
        e.to_s
      end
    end
  end
end
