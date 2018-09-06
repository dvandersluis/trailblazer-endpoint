module Trailblazer
  class Endpoint
    module Handlers
      class Base
        extend Uber::InheritableAttr

        inheritable_attr :handlers
        self.handlers = {}

        def self.on(*names, &block)
          names.each do |name|
            handlers[name] = block
          end
        end

        def call
          ->(m) do
            self.class.handlers.each do |name, proc|
              m.__send__(name) do |result|
                instance_exec(result, &proc)
              end
            end
          end
        end
      end
    end
  end
end
