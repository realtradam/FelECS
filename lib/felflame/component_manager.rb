# frozen_string_literal: true

module FelFlame
  module Components
    @component_map = []
    class << self
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
        update_const_cache

        attrs.each do |attr|
          if FelFlame::Components.const_get(component_name).method_defined?(attr.to_s) || FelFlame::Components.const_get(component_name).method_defined?("#{attr}=")
            raise NameError, "The attribute name \"#{attr}\" is already a method"
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

      # Stores the components managers in {FelFlame::Components}. This
      # is needed because calling `FelFlame::Components.constants`
      # will not let you iterate over the value of the constants
      # but will instead give you an array of symbols. This caches
      # the convertion of those symbols to the actual value of the
      # constants
      # @!visibility private
      def const_cache
        @const_cache || update_const_cache
      end

      # Updates the array that stores the constants.
      # Used internally by FelFlame
      # @!visibility private
      def update_const_cache
        @const_cache = constants.map do |constant|
          const_get constant
        end
      end

      # Forwards undefined methods to the array of constants
      # if the array can handle the request. Otherwise tells
      # the programmer their code errored
      # @!visibility private
      def respond_to_missing?(method, *)
        if const_cache.respond_to? method
          true
        else
          super
        end
      end

      # Makes component module behave like arrays with additional
      # methods for managing the array
      # @!visibility private
      def method_missing(method, *args, **kwargs, &block)
        if const_cache.respond_to? method
          const_cache.send(method, *args, **kwargs, &block)
        else
          super
        end
      end
    end
  end

  # Component Managers are what is used to create individual components which can be attached to entities.
  # When a Component is created from a Component Manager that has accessors given to it, you can set or get the values of those accessors using standard ruby message sending (e.g +@component.var = 5+), or by using the {#to_h} and {#update_attrs} methods instead.
  class ComponentManager
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
      # in FelFlame::Components)
      set_defaults

      # Fill params
      attrs.each do |key, value|
        send "#{key}=", value
      end

      # Save Component
      self.class.push self
    end

    class << self
      # Makes component managers behave like arrays with additional
      # methods for managing the array
      # @!visibility private
      def respond_to_missing?(method, *)
        if _data.respond_to? method
          true
        else
          super
        end
      end

      # Makes component managers behave like arrays with additional
      # methods for managing the array
      # @!visibility private
      def method_missing(method, *args, **kwargs, &block)
        if _data.respond_to? method
          _data.send(method, *args, **kwargs, &block)
        else
          super
        end
      end

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
      def _data
        @data ||= []
      end
    end

    # Entities that have this component
    # @return [Array<Component>]
    def entities
      @entities ||= []
    end

    # A single entity. Use this if you expect the component to only belong to one entity and you want to access it.
    # @return [Component]
    def entity
      if entities.empty?
        Warning.warn("This component belongs to NO entities but you called the method that is intended for components belonging to a single entity.\nYou may have a bug in your logic.")
      elsif entities.length > 1
        Warning.warn("This component belongs to MANY entities but you called the method that is intended for components belonging to a single entity.\nYou may have a bug in your logic.")
      end
      entities.first
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
    # @!visibility private
    def attr_changed_trigger_systems(attr)
      systems_to_execute = self.class.attr_triggers[attr]
      systems_to_execute = [] if systems_to_execute.nil?

      systems_to_execute |= attr_triggers[attr] unless attr_triggers[attr].nil?

      systems_to_execute.sort_by(&:priority).reverse_each(&:call)
      true
    end

    # Removes this component from the list and purges all references to this Component from other Entities, as well as its data.
    # @return [Boolean] +true+.
    def delete
      addition_triggers.each do |system|
        system.clear_triggers component_or_manager: self
      end
      entities.reverse_each do |entity|
        entity.remove self
      end
      self.class._data.delete self
      instance_variables.each do |var|
        instance_variable_set(var, nil)
      end
      true
    end

    # @return [Hash<Symbol, Value>] A hash, where all the keys are attributes storing their respective values.
    def to_h
      return_hash = instance_variables.each_with_object({}) do |key, final|
        final[key.to_s.delete_prefix('@').to_sym] = instance_variable_get(key)
      end
      return_hash.delete(:attr_triggers)
      return_hash
    end

    # Export all data into a JSON String, which could then later be loaded or saved to a file
    # TODO: This function is not yet complete
    # @return [String] a JSON formatted String
    # def to_json
    #  # should return a json or hash of all data in this component
    # end
  end
end
