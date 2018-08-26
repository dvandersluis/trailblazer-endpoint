require "trailblazer/endpoint"

module Trailblazer::Endpoint::Handlers
  # Generic matcher handlers for a Rails API backend.
  #
  # Note that the path mechanics are experimental. PLEASE LET US KNOW WHAT
  # YOU NEED/HOW YOU DID IT: https://gitter.im/trailblazer/chat
  class Rails
    def initialize(controller, options)
      @controller = controller
    end

    attr_reader :controller

    def call
      ->(m) do
        m.not_found       { |result| controller.head 404 }
        m.unauthenticated { |result| controller.head 401 }
        m.present         { |result| controller.render json: result["representer.serializer.class"].new(result[:model]), status: 200 }
        m.created         { |result| controller.head 201, location: controller.url_for([result[:model], only_path: true]) }
        m.success         { |result| controller.head 200, location: controller.url_for([result[:model], only_path: true]) }
        m.invalid         { |result| controller.render json: result["representer.errors.class"].new(result['result.contract.default'].errors).to_json, status: 422 }
      end
    end
  end
end
