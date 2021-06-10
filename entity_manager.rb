class FelFlame
  class Entities
    # Holds the unique ID of this entity
    # @return [Integer]
    attr_accessor :id

    # Creating a new component
    # @param components [Component] Can be any number of components, identical duplicated will be automatically purged however different components from the same component manager are allowed.
    def initialize(*components)
      # Assign new unique ID
      new_id = self.class.data.find_index { |i| i.nil? }
      new_id = self.class.data.size if new_id.nil?
      self.id = new_id

      # Add each component
      components.uniq.each do |component|
        add component
      end
      self.class.data[id] = self
    end

    # A hash that uses component manager constant names as keys, and where the values of those keys are arrays that contain the IDs of components attached to this entity.
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
          FelFlame.const_get(
            component_manager.to_s.delete_prefix('FelFlame::')
          )[component_id].linked_entities.delete(id)
        end
      end
      FelFlame::Entities.data[id] = nil
      @id = nil
      @components = nil
      true
    end

    # Returns true when added, or false if it already belongs to the Entity
    # Add a component to the Entity
    # @param component [Component] A component created from any component manager
    # @return [Boolean] true if component is added, false if it already is attached
    def add component
      if components[component.class.to_s.to_sym].nil?
        components[component.class.to_s.to_sym] = [component.id]
        component.linked_entities.push id
        true
      elsif !components[component.class.to_s.to_sym].include? component.id
        components[component.class.to_s.to_sym].push component.id
        component.linked_entities.push id
        true
      else
        false
      end
    end

    # Remove a component from the Entity
    # @param component [Component] A component created from any component manager
    # @return [Boolean] true if component is removed, false if it wasnt attached to component
    def remove component
      components[component.class.to_s.to_sym].delete component.id
      if component.linked_entities.delete id
        true
      else
        false
      end
    end

    # Export all data into a JSON String which can then be saved into a file
    # TODO: This function is not yet complete
    # @return [String] A JSON formatted String
    def to_json
    end

    class <<self
      include Enumerable
      # @return [Array] Array of all Entities that exist
      # @!visibility private
      def data
        @data ||= []
      end

      # Gets an Entity from the given unique ID. Usage is simular to how an Array lookup works
      # @param entity_id [Integer]
      # @return [Entity] returns the Entity that uses the given unique ID, nil if there is no Entity associated with the given ID
      def [](entity_id)
        data[entity_id]
      end

      # Iterates over all entities. In general when using ECS the use of this method should never be neccassary unless you are doing something very wrong, however I will not stop you.
      # You also call other enumerable methods instead of each, such as `each_with_index` or `select`
      # @return [Enumerator]
      def each(&block)
        data.each(&block)
      end
    end
  end
end
