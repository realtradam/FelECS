module FelFlame
  class Entities

    # Creating a new Entity
    # @param components [Components] Can be any number of components, identical duplicates will be automatically purged however different components from the same component manager are allowed.
    # @return [Entity]
    def initialize(*components)
      # Add each component
      add(*components)

      self.class._data.push self
    end

    # A hash that uses component manager constant names as keys, and where the values of those keys are arrays that contain the the components attached to this entity.
    # @return [Hash<Component_Manager, Array<Integer>>]
    def components
      @components ||= {}
    end

    # Removes this Entity from the list and purges all references to this Entity from other Components, as well as its data.
    # @return [Boolean] +true+
    def delete
      components.each do |component_manager, component_array|
        component_array.reverse_each do |component|
          component.entities.delete(self)
        end
      end
      FelFlame::Entities._data.delete self
      @components = {}
      true
    end

    # Add any number components to the Entity.
    # @param components_to_add [Component] Any number of components created from any component manager
    # @return [Boolean] +true+
    def add(*components_to_add)
      components_to_add.each do |component|
        if components[component.class].nil?
          components[component.class] = [component]
          component.entities.push self
          check_systems component, :addition_triggers
        elsif !components[component.class].include? component
          components[component.class].push component
          component.entities.push self
          check_systems component, :addition_triggers
        end
      end
      true
    end

    # triggers every system associated with this component's trigger
    # @return [Boolean] +true+
    # @!visibility private
    def check_systems(component, trigger_type)
      component_calls = component.class.send(trigger_type)
      component.send(trigger_type).each do |system|
        component_calls |= [system]
      end
      component_calls.sort_by(&:priority).reverse.each(&:call)
      true
    end

    # Remove a component from the Entity
    # @param components_to_remove [Component] A component created from any component manager
    # @return [Boolean] +true+
    def remove(*components_to_remove)
      components_to_remove.each do |component|
        check_systems component, :removal_triggers if component.entities.include? self
        component.entities.delete self
        components[component.class].delete component
      end
      true
    end

    # Export all data into a JSON String which can then be saved into a file
    # TODO: This function is not yet complete
    # @return [String] A JSON formatted String
    #def to_json() end

    class <<self
      #include Enumerable

      # Makes component managers behave like arrays with additional
      # methods for managing the array
      # @!visibility private
      def respond_to_missing?(method, *)
        if self._data.respond_to? method
          true
        else
          super
        end
      end

      # Makes component managers behave like arrays with additional
      # methods for managing the array
      # @!visibility private
      def method_missing(method, *args, **kwargs, &block)
        if self._data.respond_to? method
          self._data.send(method, *args, **kwargs, &block)
        else
          super
        end
      end


      # @return [Array<Entity>] Array of all Entities that exist
      # @!visibility private
      def _data
        @data ||= []
      end

      # Creates a new entity using the data from a JSON string
      # TODO: This function is not yet complete
      # @param json_string [String] A string that was exported originally using the {FelFlame::Entities#to_json to_json} function
      # @param opts [Keywords] What values(its {FelFlame::Entities#id ID} or the {FelFlame::ComponentManager#id component IDs}) should be overwritten TODO: this might change
      #def from_json(json_string, **opts) end
    end
  end
end
