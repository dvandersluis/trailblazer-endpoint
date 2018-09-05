require "trailblazer/endpoint/matcher"

module Trailblazer
  class Endpoint
    # `call`s the operation.
    def self.call(operation_class, matcher, handlers, *args, &block)
      result = operation_class.(*args)
      new.(result, matcher.(), handlers, &block)
    end

    def call(result, matcher, handlers=nil, &block)
      matcher.(result, &block) and return if block_given? # evaluate user blocks first.
      matcher.(result, &handlers)     # then, generic Rails handlers in controller context.
    end

    module Controller
      # endpoint(Create) do |m|
      #   m.not_found { |result| .. }
      # end
      def endpoint(operation_class, matcher: Matcher, **options, &block)
        handlers = Handlers::Rails.new(self, options).()
        args = { params: params, present: options[:present] }.merge(options.fetch(:args, {}))
        Endpoint.(operation_class, matcher, handlers, args, &block)
      end
    end
  end
end
