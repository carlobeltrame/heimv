class BookingStrategy
  class Action
    class NotAllowed < StandardError; end
    include Translatable
    attr_reader :context

    def initialize(context)
      @context = context
    end

    def call
      raise NotAllowed unless allowed?

      call!
    end

    def self.call(context)
      new(context).call
    end

    def self.action_name
      name.demodulize.underscore
    end

    def to_s
      self.class.action_name
    end

    def button_options
      {
        variant: 'secondary'
      }
    end
  end
end
