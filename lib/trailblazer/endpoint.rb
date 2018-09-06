require "trailblazer/endpoint/matcher"

module Trailblazer
  class Endpoint
    # `call`s the operation.
    def self.call(operation_class, matcher, handlers, *args, &block)
      result = operation_class.(*args)
      new.(result, matcher.(), handlers, &block)
    end

    def call(result, matcher, handlers=nil)
      matcher.(result, &handlers)
    end

    module Controller
      def endpoint(operation_class, matcher: Matcher, handler: Handlers::Rails, **options, &block)
        handler = Class.new(handler)
        handler.class_eval(&block) if block_given?

        args = { params: params, present: options[:present] }.merge(options.fetch(:args, {}))
        Endpoint.(operation_class, matcher, handler.new(self, options).(), args)
      end
    end
  end
end
