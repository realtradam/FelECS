class FelFlame
  class Entities
    # Holds the unique ID of this entity
    # @return [Integer]
    attr_reader :id

    # A seperate attr_writer was made for documentation readability reasons.
    # Yard will list attr_reader is readonly which is my intention.
    # This value needs to be changable as it is set by other functions.
    # @!visibility private
    attr_writer :id

    # Creating a new Entity
    # @param components [Components] Can be any number of components, identical duplicates will be automatically purged however different components from the same component manager are allowed.
    # @return [Entity]
    def initialize(*components)
      # Assign new unique ID
      new_id = self.class.data.find_index(&:nil?)
      new_id = self.class.data.size if new_id.nil?
      self.id = new_id

      # Add each component
      #components.uniq.each do |component|
      #  add component
      #end
      add(*components)

      self.class.data[id] = self
    end

    # A hash that uses component manager constant names as keys, and where the values of those keys are arrays that contain the {FelFlame::Helper::ComponentManager#id IDs} of the components attached to this entity.
    # @return [Hash]
    def components
      @components ||= {}
    end

    # An alias for the {#id ID reader}
    # @return [Integer]
    def to_i
      id
    end

    # Removes this Entity from the list and purges all references to this Entity from other Components, as well as its {id ID} and data.
    # @return [Boolean] true.
    def delete
      components.each do |component_manager, component_array|
        component_array.each do |component_id|
          component_manager[component_id].entities.delete(id)
          #self.remove FelFlame::Components.const_get(component_manager.name)[component_id]
        end
      end
      FelFlame::Entities.data[id] = nil
      @components = {}
      @id = nil
      true
    end

    # Add any number components to the Entity.
    # @param components_to_add [Component] Any number of components created from any component manager
    # @return [Boolean] true if component is added, false if it already is attached or no components given
    def add(*components_to_add)
      components_to_add.each do |component|
        if components[component.class].nil?
          components[component.class] = [component.id]
          component.entities.push id
          check_systems component, :addition_triggers
        elsif !components[component.class].include? component.id
          components[component.class].push component.id
          component.entities.push id
          check_systems component, :addition_triggers
        end
      end
    end

    # triggers every system associated with this component's trigger
    # @return [Boolean] true
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
    # @return [Boolean] true if at least one component is removed, false if none of them were attached to the component
    def remove(*components_to_remove)
      components_to_remove.each do |component|
        check_systems component, :removal_triggers if component.entities.include? id
        component.entities.delete id
        components[component.class].delete component.id
      end
      true
    end

    # Export all data into a JSON String which can then be saved into a file
    # TODO: This function is not yet complete
    # @return [String] A JSON formatted String
    def to_json() end

    class <<self
      include Enumerable
      # @return [Array<Entity>] Array of all Entities that exist
      # @!visibility private
      def data
        @data ||= []
      end

      # Gets an Entity from the given {id unique ID}. Usage is simular to how an Array lookup works
      #
      # @example
      #   # This gets the Entity with ID 7
      #   FelFlame::Entities[7]
      # @param entity_id [Integer]
      # @return [Entity] returns the Entity that uses the given unique ID, nil if there is no Entity associated with the given ID
      def [](entity_id)
        data[entity_id]
      end

      # Iterates over all entities. The data is compacted so that means index does not correlate to ID.
      # You also call other enumerable methods instead of each, such as +each_with_index+ or +select+
      # @return [Enumerator]
      def each(&block)
        data.compact.each(&block)
      end

      # Creates a new entity using the data from a JSON string
      # TODO: This function is not yet complete
      # @param json_string [String] A string that was exported originally using the {FelFlame::Entities#to_json to_json} function
      # @param opts [Keywords] What values(its {FelFlame::Entities#id ID} or the {FelFlame::Helper::ComponentManager#id component IDs}) should be overwritten TODO: this might change
      def from_json(json_string, **opts) end
    end
  end
end
