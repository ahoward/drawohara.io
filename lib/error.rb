class Error < ::StandardError
  attr_reader :data
  attr_reader :messages

  def initialize(*args, **kws, &block)
    @data = kws
    @messages = []

    args.each do |arg|
      case arg
        when Hash
          @data.update(arg)
        else
          @messages.push(arg)
      end
    end

    message = @messages.join(', ')

    super(message)
  end
end
