require 'trailblazer/endpoint'
require 'trailblazer/endpoint/handlers/base'

module Trailblazer::Endpoint::Handlers
  # Generic matcher handlers for a Rails API backend.
  class Rails < Base
    def initialize(controller, options)
      @controller = controller
      @representer = options[:present] if options[:present].is_a?(Class)
    end

    attr_reader :controller

    on(:not_found) do
      controller.head 404
    end

    on(:unauthenticated) do
      controller.head 401
    end

    on(:created) do |result|
      if @representer
        controller.render json: @representer.new(result[:model]), status: 201
      else
        controller.head 201, location: controller.url_for([result[:model], only_path: true])
      end
    end

    on(:present) do |result|
      representer = @representer || result['representer.serializer.class']
      controller.render json: representer.new(result[:model]), status: 200
    end

    on(:success) do |result|
      controller.head 200, location: controller.url_for([result[:model], only_path: true])
    end

    on(:invalid) do |result|
      controller.render json: result['representer.errors.class'].new(result['result.contract.default'].errors).to_json, status: 422
    end

    on(:failure) do
      controller.head 500
    end

    on(:other) do
      controller.head 204
    end
  end
end
