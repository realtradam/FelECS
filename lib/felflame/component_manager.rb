class FelFlame
  class Components
    @component_map = []
    class <<self
      include Enumerable
      # Creates a new {FelFlame::ComponentManager component manager}.
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


        const_set(component_name, Class.new(FelFlame::ComponentManager) {})

        attrs.each do |attr|
          if FelFlame::Components.const_get(component_name).method_defined?("#{attr}") || FelFlame::Components.const_get(component_name).method_defined?("#{attr}=")
            raise NameError.new "The attribute name \"#{attr}\" is already a method"
          end
          FelFlame::Components.const_get(component_name).attr_accessor attr
        end
        attrs_with_defaults.each do |attr, _default|
          attrs_with_defaults[attr] = _default.dup
          FelFlame::Components.const_get(component_name).attr_reader attr
          FelFlame::Components.const_get(component_name).define_method("#{attr}=") do |value|
            attr_changed_trigger_systems(attr) unless value.equal? send(attr)
            instance_variable_set("@#{attr}", value)
          end
        end
        FelFlame::Components.const_get(component_name).define_method(:set_defaults) do
          attrs_with_defaults.each do |attr, default|
            instance_variable_set("@#{attr}", default.dup)
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

  # Component Managers are what is used to create individual components which can be attached to entities.
  # When a Component is created from a Component Manager that has accessors given to it, you can set or get the values of those accessors using standard ruby message sending (e.g +@component.var = 5+), or by using the {#attrs} and {#update_attrs} methods instead.
  class ComponentManager

    # Holds the {id unique ID} of a component. The {id ID} is only unique within the scope of the component manager it was created from.
    # @return [Integer]
    attr_reader :id

    # A seperate attr_writer was made for documentation readability reasons.
    # Yard will list attr_reader is readonly which is my intention.
    # This value needs to be changable as it is set by other functions.
    # @!visibility private
    attr_writer :id

    # Allows overwriting the storage of triggers, such as for clearing.
    # This method should generally only need to be used internally and
    # not by a game developer.
    # @!visibility private
    attr_writer :addition_triggers, :removal_triggers, :attr_triggers

    # Stores references to systems that should be triggered when a
    # component from this manager is added.
    # Do not edit this array as it is managed by FelFlame automatically.
    # @return [Array<System>]
    def addition_triggers
      @addition_triggers ||= []
    end

    # Stores references to systems that should be triggered when a
    # component from this manager is removed.
    # Do not edit this array as it is managed by FelFlame automatically.
    # @return [Array<System>]
    def removal_triggers
      @removal_triggers ||= []
    end

    # Stores references to systems that should be triggered when an
    # attribute from this manager is changed.
    # Do not edit this hash as it is managed by FelFlame automatically.
    # @return [Hash<Symbol, Array<System>>]
    def attr_triggers
      @attr_triggers ||= {}
    end

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

      # Allows overwriting the storage of triggers, such as for clearing.
      # This method should generally only need to be used internally and
      # not by a game developer.
      # @!visibility private
      attr_writer :addition_triggers, :removal_triggers, :attr_triggers

      # Stores references to systems that should be triggered when this
      # component is added to an enitity.
      # Do not edit this array as it is managed by FelFlame automatically.
      # @return [Array<System>]
      def addition_triggers
        @addition_triggers ||= []
      end

      # Stores references to systems that should be triggered when this
      # component is removed from an enitity.
      # Do not edit this array as it is managed by FelFlame automatically.
      # @return [Array<System>]
      def removal_triggers
        @removal_triggers ||= []
      end

      # Stores references to systems that should be triggered when an
      # attribute from this component changed.
      # Do not edit this hash as it is managed by FelFlame automatically.
      # @return [Hash<Symbol, System>]
      def attr_triggers
        @attr_triggers ||= {}
      end

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
    # @return [Hash<Symbol, Value>] Hash of updated attributes
    def update_attrs(**opts)
      opts.each do |key, value|
        send "#{key}=", value
      end
    end

    # Execute systems that have been added to execute on variable change
    # @return [Boolean] +true+
    def attr_changed_trigger_systems(attr)
      systems_to_execute = self.class.attr_triggers[attr]
      systems_to_execute = [] if systems_to_execute.nil?

      systems_to_execute |= attr_triggers[attr] unless attr_triggers[attr].nil?

      systems_to_execute.sort_by(&:priority).reverse.each(&:call)
      true
    end

    # Removes this component from the list and purges all references to this Component from other Entities, as well as its {id ID} and data.
    # @return [Boolean] +true+.
    def delete
      addition_triggers.each do |system|
        system.clear_triggers component_or_manager: self
      end
      # This needs to be cloned because indices get deleted as
      # the remove command is called, breaking the loop if it
      # wasn't referencing a clone(will get Nil errors)
      iter = entities.map(&:clone)
      iter.each do |entity|
        #FelFlame::Entities[entity_id].remove self #unless FelFlame::Entities[entity_id].nil?
        entity.remove self
      end
      self.class.data[id] = nil
      instance_variables.each do |var|
        instance_variable_set(var, nil)
      end
      true
    end

    # @return [Hash<Symbol, Value>] A hash, where all the keys are attributes linked to their respective values.
    def attrs
      return_hash = instance_variables.each_with_object({}) do |key, final|
        final[key.to_s.delete_prefix('@').to_sym] = instance_variable_get(key)
      end
      return_hash.delete(:attr_triggers)
      return_hash
    end

    # Export all data into a JSON String, which could then later be loaded or saved to a file
    # TODO: This function is not yet complete
    # @return [String] a JSON formatted String
    #def to_json
    #  # should return a json or hash of all data in this component
    #end
  end
end
