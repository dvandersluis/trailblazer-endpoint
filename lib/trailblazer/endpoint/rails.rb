require 'trailblazer/endpoint'

module Trailblazer::Endpoint::Handlers
  # Generic matcher handlers for a Rails API backend.
  #
  # Note that the path mechanics are experimental. PLEASE LET US KNOW WHAT
  # YOU NEED/HOW YOU DID IT: https://gitter.im/trailblazer/chat
  class Rails
    def initialize(controller, options)
      @controller = controller
      @representer = options[:present] if options[:present].is_a?(Class)
    end

    attr_reader :controller

    def call
      ->(m) do
        m.not_found do
          controller.head 404
        end

        m.unauthenticated do
          controller.head 401
        end

        m.created do |result|
          if @representer
            controller.render json: @representer.new(result[:model]), status: 201
          else
            controller.head 201, location: controller.url_for([result[:model], only_path: true])
          end
        end

        m.present do |result|
          representer = @representer || result['representer.serializer.class']
          controller.render json: representer.new(result[:model]), status: 200
        end

        m.success do |result|
          controller.head 200, location: controller.url_for([result[:model], only_path: true])
        end

        m.invalid do |result|
          controller.render json: result['representer.errors.class'].new(result['result.contract.default'].errors).to_json, status: 422
        end

        m.other do
          controller.head 204
        end

        m.failure do
          controller.head 500
        end
      end
    end
  end
end
