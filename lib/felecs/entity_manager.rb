# frozen_string_literal: true

module FelECS
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

    # A single component from a component manager. Use this if you expect the component to only belong to one entity and you want to access it. Access the component using either parameter notation or array notation. Array notation is conventional for better readablility.
    # @example
    #   @entity.component[@component_manager] # array notation(the standard)
    #   @entity.component(@component_manager) # method notation
    # @param manager [ComponentManager] If you pass nil you can then use array notation to access the same value.
    # @return [Component]
    def component(manager = nil)
      if manager.nil?
        FelECS::Entities.component_redirect.entity = self
        FelECS::Entities.component_redirect
      else
        if components[manager].nil?
          raise "This entity(#{self}) doesnt have any components of this type: #{manager}"
        elsif components[manager].length > 1
          Warning.warn("This entity has MANY of this component but you called the method that is intended for having a single of this component type.\nYou may have a bug in your logic.")
        end

        components[manager].first
      end
    end

    # Removes this Entity from the list and purges all references to this Entity from other Components, as well as its data.
    # @return [Boolean] +true+
    def delete
      components.each do |_component_manager, component_array|
        component_array.reverse_each do |component|
          component.entities.delete(self)
        end
      end
      FelECS::Entities._data.delete self
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
        components.delete component.class if components[component.class].empty?
      end
      true
    end

    # Export all data into a JSON String which can then be saved into a file
    # TODO: This function is not yet complete
    # @return [String] A JSON formatted String
    # def to_json() end

    class << self
      # Selects every entity that has components of they type passed into
      # this function and then executes the code block for those components
      # and entities.
      # @return [Nil]
      def group(*component_managers, &block)
        return nil if component_managers.empty?

        if component_managers.length == 1
          component_managers.first.each do |cmp|
            block.call(cmp, cmp.entity)
          end
        else
          arry = component_managers.first.select do |cmp|
            ent = cmp.entity
            keep = true
            component_managers.drop(1).each do |mgr|
              next unless ent.components[mgr].nil?

              keep = false
              break
            end
            keep
          end
          arry.each do |cmp|
            ent = cmp.entity
            cmp_arry = [cmp]
            component_managers.drop(1).each do |cmp_mgr|
              cmp_arry.push ent.component[cmp_mgr]
            end
            block.call(*cmp_arry, ent)
          end
        end
        nil
      end

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

      # Fancy method redirection for when the `component` method is called
      # in an Entity
      # WARNING: This method will not correctly work with multithreading
      # @!visibility private
      def component_redirect
        if @component_redirect
        else
          @component_redirect = Object.new
          @component_redirect.instance_variable_set(:@entity, nil)
          @component_redirect.define_singleton_method(:entity) do
            instance_variable_get(:@entity)
          end
          @component_redirect.define_singleton_method(:entity=) do |value|
            instance_variable_set(:@entity, value)
          end
          @component_redirect.define_singleton_method(:[]) do |component_manager|
            entity.component(component_manager)
          end
        end
        @component_redirect
      end

      # @return [Array<Entity>] Array of all Entities that exist
      # @!visibility private
      def _data
        @data ||= []
      end

      # Creates a new entity using the data from a JSON string
      # TODO: This function is not yet complete
      # @param json_string [String] A string that was exported originally using the {FelECS::Entities#to_json to_json} function
      # @param opts [Keywords] What values(its {FelECS::Entities#id ID} or the {FelECS::ComponentManager#id component IDs}) should be overwritten TODO: this might change
      # def from_json(json_string, **opts) end
    end
  end
end
