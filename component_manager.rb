#require 'app/ECS/base_component.rb'

#require 'app/ECS/components/00_test_component.rb'
#require 'app/ECS/components/01_based.rb'
class FelFlame
  class Components
    @component_map = []
    class <<self
      include Enumerable
      # Creates a new {FelFlame::Helper::ComponentManager component manager}.
      #
      # @example
      #   # Here color is set to default to red
      #   # while max and current are nil until set.
      #   # When you make a new component using this component manager
      #   # these are the values and accessors it will have.
      #   FelFlame::Component.new('Health', :max, :current, color: 'red')
      #
      # @param component_name [String] Name of your new component manager. Must be stylized in the format of constants in Ruby
      # @param attrs [:Symbols] New components made with this manager will include these symbols as accessors, the values of these accessors will default to nil
      # @param attrs_with_defaults [Keyword: DefaultValue] New components made with this manager will include these keywords as accessors, their defaults set to the values given to the keywords
      # @return [ComponentManager]
      def new(component_name, *attrs, **attrs_with_defaults)
        if FelFlame::Components.const_defined?(component_name)
          raise(NameError.new, "Component Manager '#{component_name}' is already defined")
        end

        const_set(component_name, Class.new(FelFlame::Helper::ComponentManager) {})
        attrs.each do |attr|
          FelFlame::Components.const_get(component_name).attr_accessor attr
        end
        attrs_with_defaults.each do |attr, _default|
          FelFlame::Components.const_get(component_name).attr_accessor attr
        end
        FelFlame::Components.const_get(component_name).define_method(:set_defaults) do
          attrs_with_defaults.each do |attr, default|
            instance_variable_set("@#{attr}", default)
          end
        end
        FelFlame::Components.const_get(component_name)
      end

      # Iterate over all existing component managers. You also call other enumerable methods instead of each, such as +each_with_index+ or +select+
      # @return [Enumerator]
      def each(&block)
        constants.each(&block)
      end
    end
  end
  # Namespace for helper functions and template classes
  class Helper
    # Component Managers are what is used to create individual components which can be attached to entities.
    # When a Component is created from a Component Manager that has accessors given to it, you can set or get the values of those accessors using standard ruby message sending (e.g +@component.var = 5+), or by using the {#attrs} and {#update_attrs} methods instead.
    class ComponentManager
      # Holds the {id unique ID} of a component. The {id ID} is only unique within the scope of the component manager it was created from.
      # @return [Integer]
      attr_accessor :id

      # Creates a new component and sets the values of the attributes given to it. If an attritbute is not passed then it will remain as the default.
      # @param attrs [Keyword: Value] You can pass any number of Keyword-Value pairs
      # @return [Component]
      def initialize(**attrs)
        # Prepare the object
        # (this is a function created with metaprogramming
        # in FelFlame::Components
        set_defaults

        # Generate ID
        new_id = self.class.data.find_index { |i| i.nil? }
        new_id = self.class.data.size if new_id.nil?
        @id = new_id

        # Fill params
        attrs.each do |key, value|
          send "#{key}=", value
        end

        # Save Component
        self.class.data[new_id] = self
      end

      class <<self
        # @return [Array<Component>] Array of all Components that belong to a given component manager
        # @!visibility private
        def data
          @data ||= []
        end

        # Gets a Component from the given {id unique ID}. Usage is simular to how an Array lookup works.
        #
        # @example
        #   # this gets the 'Health' Component with ID 7
        #   FelFlame::Components::Health[7]
        # @param component_id [Integer]
        # @return [Component] Returns the Component that uses the given unique {id ID}, nil if there is no Component associated with the given {id ID}
        def [](component_id)
          data[component_id]
        end

        # Iterates over all components within the component manager.
        # Special Enumerable methods like +map+ or +each_with_index+ are not implemented
        # @return [Enumerator]
        def each(&block)
          data.compact.each(&block)
        end
      end

      # An alias for the {id ID Reader}
      # @return [Integer]
      def to_i
        id
      end

      # A list of entity ids that are linked to the component
      # @return [Array<Integer>]
      def entities
        @entities ||= []
      end

      # Update attribute values using a hash or keywords.
      # @return Hash of updated attributes
      def update_attrs(**opts)
        opts.each do |key, value|
          send "#{key}=", value
        end
      end

      # Removes this component from the list and purges all references to this Component from other Entities, as well as its {id ID} and data.
      # @return [Boolean] true.
      def delete
        entities.each do |entity_id|
          FelFlame::Entities[entity_id].remove self
        end
        self.class.data[id] = nil
        @entities = nil
        instance_variables.each do |var|
          instance_variable_set(var, nil)
        end
        true
      end

      # @return [Hash] A hash, where all the keys are attributes linked to their respective values.
      def attrs
        instance_variables.each_with_object({}) do |key, final|
          final[key.to_s.delete_prefix('@').to_sym] = instance_variable_get(key)
        end
      end

      # Export all data into a JSON String, which could then later be loaded or saved to a file
      # TODO: This function is not yet complete
      # @return [String] a JSON formatted String
      def to_json
        # should return a json or hash of all data in this component
      end
    end
  end
end
