require 'dry/matcher'
require 'uber/inheritable_attr'

module Trailblazer
  class Endpoint
    class Matcher
      extend Uber::InheritableAttr

      inheritable_attr :cases
      self.cases = {}

      class << self
        def match(name, &match_proc)
          cases[name] = Dry::Matcher::Case.new(
            match: match_proc,
            resolve: :itself.to_proc
          )
        end

        def call
          Dry::Matcher.new(self.cases)
        end
      end

      match(:present) do |result|
        result.success? && result[:present]
      end

      match(:success, &:success?)

      match(:created) do |result|
        result.success? && result['model.action'] == :new
        # the "model.action" doesn't mean you need Model.
      end

      match(:not_found) do |result|
        result.failure? && result['result.model'] && result['result.model'].failure?
      end

      # TODO: we could add unauthorized here.

      match(:unauthenticated) do |result|
        result.failure? && result['result.policy.default'] && result['result.policy.default'].failure?
      end

      match(:invalid) do |result|
        result.failure? && result['result.contract.default'] && result['result.contract.default'].failure?
      end

      match(:other) do |*|
        true
      end
    end
  end
end
