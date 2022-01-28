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

# frozen_string_literal: true

module FelECS
  module Components
    @component_map = []
    class << self
      # Creates a new {FelECS::ComponentManager component manager}.
      #
      # @example
      #   # Here color is set to default to red
      #   # while max and current are nil until set.
      #   # When you make a new component using this component manager
      #   # these are the values and accessors it will have.
      #   FelECS::Component.new('Health', :max, :current, color: 'red')
      #
      # @param component_name [String] Name of your new component manager. Must be stylized in the format of constants in Ruby
      # @param attrs [:Symbols] New components made with this manager will include these symbols as accessors, the values of these accessors will default to nil
      # @param attrs_with_defaults [Keyword: DefaultValue] New components made with this manager will include these keywords as accessors, their defaults set to the values given to the keywords
      # @return [ComponentManager]
      def new(component_name, *attrs, **attrs_with_defaults)
        if FelECS::Components.const_defined?(component_name)
          raise(NameError.new, "Component Manager '#{component_name}' is already defined")
        end

        const_set(component_name, Class.new(FelECS::ComponentManager) {})
        update_const_cache

        attrs.each do |attr|
          if FelECS::Components.const_get(component_name).method_defined?(attr.to_s) || FelECS::Components.const_get(component_name).method_defined?("#{attr}=")
            raise NameError, "The attribute name \"#{attr}\" is already a method"
          end

          FelECS::Components.const_get(component_name).attr_accessor attr
        end
        attrs_with_defaults.each do |attr, _default|
          attrs_with_defaults[attr] = _default.dup
          FelECS::Components.const_get(component_name).attr_reader attr
          FelECS::Components.const_get(component_name).define_method("#{attr}=") do |value|
            unless value.equal? send(attr)
              instance_variable_set("@#{attr}", value)
              attr_changed_trigger_systems(attr)
            end
          end
        end
        FelECS::Components.const_get(component_name).define_method(:set_defaults) do
          attrs_with_defaults.each do |attr, default|
            instance_variable_set("@#{attr}", default.dup)
          end
        end
        FelECS::Components.const_get(component_name)
      end

      # Stores the components managers in {FelECS::Components}. This
      # is needed because calling `FelECS::Components.constants`
      # will not let you iterate over the value of the constants
      # but will instead give you an array of symbols. This caches
      # the convertion of those symbols to the actual value of the
      # constants
      # @!visibility private
      def const_cache
        @const_cache || update_const_cache
      end

      # Updates the array that stores the constants.
      # Used internally by FelECS
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
    # Do not edit this array as it is managed by FelECS automatically.
    # @return [Array<System>]
    def addition_triggers
      @addition_triggers ||= []
    end

    # Stores references to systems that should be triggered when a
    # component from this manager is removed.
    # Do not edit this array as it is managed by FelECS automatically.
    # @return [Array<System>]
    def removal_triggers
      @removal_triggers ||= []
    end

    # Stores references to systems that should be triggered when an
    # attribute from this manager is changed.
    # Do not edit this hash as it is managed by FelECS automatically.
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
      # in FelECS::Components)
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
      # Do not edit this array as it is managed by FelECS automatically.
      # @return [Array<System>]
      def addition_triggers
        @addition_triggers ||= []
      end

      # Stores references to systems that should be triggered when this
      # component is removed from an enitity.
      # Do not edit this array as it is managed by FelECS automatically.
      # @return [Array<System>]
      def removal_triggers
        @removal_triggers ||= []
      end

      # Stores references to systems that should be triggered when an
      # attribute from this component changed.
      # Do not edit this hash as it is managed by FelECS automatically.
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

# frozen_string_literal: true

module FelECS
  class Systems
    # How early this System should be executed in a list of Systems
    attr_accessor :priority

    # The Constant name assigned to this System

    # Allows overwriting the storage of triggers, such as for clearing.
    # This method should generally only need to be used internally and
    # not by a game developer.
    # @!visibility private
    attr_writer :addition_triggers, :removal_triggers, :attr_triggers

    # Stores all the scenes this system is a part of.
    attr_writer :scenes

    def scenes
      @scenes ||= []
    end

    def priority=(priority)
      @priority = priority
      scenes.each do |scene|
        scene.systems = scene.systems.sort_by(&:priority)
      end
    end

    # Stores references to components or their managers that trigger
    # this component when a component or component from that manager
    # is added to an entity.
    # Do not edit this hash as it is managed by FelECS automatically.
    # @return [Array<Component>]
    def addition_triggers
      @addition_triggers ||= []
    end

    # Stores references to components or their managers that trigger
    # this component when a component or component from that manager
    # is removed from an entity.
    # Do not edit this hash as it is managed by FelECS automatically.
    # @return [Array<Component>]
    def removal_triggers
      @removal_triggers ||= []
    end

    # Stores references to systems that should be triggered when an
    # attribute from this manager is changed
    # Do not edit this hash as it is managed by FelECS automatically.
    # @return [Hash<Symbol, Array<Symbol>>]
    def attr_triggers
      @attr_triggers ||= {}
    end

    class << self
      # Stores the systems in {FelECS::Components}. This
      # is needed because calling `FelECS::Components.constants`
      # will not let you iterate over the value of the constants
      # but will instead give you an array of symbols. This caches
      # the convertion of those symbols to the actual value of the
      # constants
      def const_cache
        @const_cache || update_const_cache
      end

      # Updates the array that stores the constants.
      # Used internally by FelECS
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

      # Makes system module behave like arrays with additional
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

    # Creates a new System which can be accessed as a constant under the namespace {FelECS::Systems}.
    # The name given is what constant the system is assigned to
    #
    # @example
    #   FelECS::Systems.new('PassiveHeal', priority: -2) do
    #     FelECS::Components::Health.each do |component|
    #       component.hp += 5
    #     end
    #   end
    #   # Give it a low priority so other systems such as a
    #   #   Poison system would kill the player first
    #
    # @param name [String] The name this system will use. Needs to to be in the Ruby Constant format.
    # @param priority [Integer] Which priority order this system should be executed in relative to other systems. Higher means executed earlier.
    # @param block [Proc] The code you wish to be executed when the system is triggered. Can be defined by using a +do end+ block or using +{ }+ braces.
    def initialize(name, priority: 0, &block)
      FelECS::Systems.const_set(name, self)
      FelECS::Systems.update_const_cache
      @priority = priority
      @block = block
      @scenes = []
    end

    # Manually execute the system a single time
    def call
      @block.call
    end

    # Redefine what code is executed by this System when it is called upon.
    # @param block [Proc] The code you wish to be executed when the system is triggered. Can be defined by using a +do end+ block or using +{ }+ braces.
    def redefine(&block)
      @block = block
    end

    # Removes triggers from this system. This function is fairly flexible so it can accept a few different inputs
    # For addition and removal triggers, you can optionally pass in a component, or a manager to clear specifically
    # the relevant triggers for that one component or manager. If you do not pass a component or manager then it will
    # clear triggers for all components and managers.
    # For attr_triggers
    # @example
    #   # To clear all triggers that execute this system when a component is added:
    #   FelECS::Systems::ExampleSystem.clear_triggers :addition_triggers
    #   # Same as above but for when a component is removed instead
    #   FelECS::Systems::ExampleSystem.clear_triggers :removal_triggers
    #   # Same as above but for when a component has a certain attribute changed
    #   FelECS::Systems::ExampleSystem.clear_triggers :attr_triggers
    #
    #   # Clear a trigger from a specific component
    #   FelECS::Systems::ExampleSystem.clear_triggers :addition_triggers, FelECS::Component::ExampleComponent[0]
    #   # Clear a trigger from a specific component manager
    #   FelECS::Systems::ExampleSystem.clear_triggers :addition_triggers, FelECS::Component::ExampleComponent
    #
    #   # Clear the trigger that executes a system when the ':example_attr' is changes
    #   FelECS::Systems::ExampleSystem.clear_triggers :attr_triggers, :example_attr
    # @param trigger_types [:Symbols] One or more of  the following trigger types: +:addition_triggers+, +:removal_triggers+, or +:attr_triggers+. If attr_triggers is used then you may pass attributes you wish to be cleared as symbols in this parameter as well
    # @param component_or_manager [Component or ComponentManager] The object to clear triggers from. Use Nil to clear triggers from all components associated with this system.
    # @return [Boolean] +true+
    def clear_triggers(*trigger_types, component_or_manager: nil)
      trigger_types = %i[addition_triggers removal_triggers attr_triggers] if trigger_types.empty?

      if trigger_types.include? :attr_triggers
        if (trigger_types - %i[addition_triggers
            removal_triggers
            attr_triggers]).empty?

            if component_or_manager.nil?
              # remove all attrs
              attr_triggers.each do |cmp_or_mgr, attrs|
                attrs.each do |attr|
                  next if cmp_or_mgr.attr_triggers[attr].nil?

                  cmp_or_mgr.attr_triggers[attr].delete self
                end
                self.attr_triggers = {}
              end
            else
              # remove attrs relevant to comp_or_man
              unless attr_triggers[component_or_manager].nil?
                attr_triggers[component_or_manager].each do |attr|
                  component_or_manager.attr_triggers[attr].delete self
                end
                attr_triggers[component_or_manager] = []
              end
            end

        elsif component_or_manager.nil?

          (trigger_types - %i[addition_triggers removal_triggers attr_triggers]).each do |attr|
            # remove attr
            attr_triggers.each do |cmp_or_mgr, _attrs|
              cmp_or_mgr.attr_triggers[attr].delete self
            end
          end
          attr_triggers.delete(trigger_types - %i[addition_triggers
                               removal_triggers
                               attr_triggers])
        else
          # remove attr from component_or_manager
          (trigger_types - %i[addition_triggers removal_triggers attr_triggers]).each do |attr|
            next if component_or_manager.attr_triggers[attr].nil?

            component_or_manager.attr_triggers[attr].delete self
          end
          attr_triggers[component_or_manager] -= trigger_types unless attr_triggers[component_or_manager].nil?

        end
      end

      (trigger_types & %i[removal_triggers addition_triggers] - [:attr_triggers]).each do |trigger_type|
        if component_or_manager.nil?
          # remove all removal triggers
          send(trigger_type).each do |trigger|
            trigger.send(trigger_type).delete self
          end
          send("#{trigger_type}=", [])
        else
          # remove removal trigger relevant to comp/man
          send(trigger_type).delete component_or_manager
          component_or_manager.send(trigger_type).delete self
        end
      end
      true
    end

    # Add a component or component manager so that it triggers this system when the component or a component from the component manager is added to an entity
    # @param component_or_manager [Component or ComponentManager] The component or component manager to trigger this system when added
    # @return [Boolean] +true+
    def trigger_when_added(component_or_manager)
      self.addition_triggers |= [component_or_manager]
      component_or_manager.addition_triggers |= [self]
      true
    end

    # Add a component or component manager so that it triggers this system when the component or a component from the component manager is removed from an entity
    # @param component_or_manager [Component or ComponentManager] The component or component manager to trigger this system when removed
    # @return [Boolean] +true+
    def trigger_when_removed(component_or_manager)
      self.removal_triggers |= [component_or_manager]
      component_or_manager.removal_triggers |= [self]
      true
    end

    # Add a component or component manager so that it triggers this system when a component's attribute is changed.
    # @return [Boolean] +true+
    def trigger_when_is_changed(component_or_manager, attr)
      if component_or_manager.attr_triggers[attr].nil?
        component_or_manager.attr_triggers[attr] = [self]
      else
        component_or_manager.attr_triggers[attr] |= [self]
      end
      if attr_triggers[component_or_manager].nil?
        attr_triggers[component_or_manager] = [attr]
      else
        attr_triggers[component_or_manager] |= [attr]
      end
      true
    end
  end
end

# frozen_string_literal: true

module FelECS
  class Scenes
    # Allows overwriting the storage of systems, such as for clearing.
    # This method should generally only need to be used internally and
    # not by a game developer/
    # @!visibility private
    attr_writer :systems

    # How early this Scene should be executed in a list of Scenes
    attr_accessor :priority

    def priority=(priority)
      @priority = priority
      FelECS::Stage.scenes = FelECS::Stage.scenes.sort_by(&:priority)
      priority
    end

    # Create a new Scene using the name given
    # @param name [String] String format must follow requirements of a constant
    def initialize(name, priority: 0)
      self.priority = priority
      FelECS::Scenes.const_set(name, self)
    end

    # The list of Systems this Scene contains
    # @return [Array<System>]
    def systems
      @systems ||= []
    end

    # Execute all systems in this Scene, in the order of their priority
    # @return [Boolean] +true+
    def call
      systems.each(&:call)
      true
    end

    # Adds any number of Systems to this Scene
    # @return [Boolean] +true+
    def add(*systems_to_add)
      self.systems |= systems_to_add
      self.systems = systems.sort_by(&:priority)
      systems_to_add.each do |system|
        system.scenes |= [self]
      end
      true
    end

    # Removes any number of Systems from this Scene
    # @return [Boolean] +true+
    def remove(*systems_to_remove)
      self.systems -= systems_to_remove
      true
    end

    # Removes all Systems from this Scene
    # @return [Boolean] +true+
    def clear
      systems.each do |system|
        system.scenes.delete self
      end
      systems.clear
      # FelECS::Stage.update_systems_list if FelECS::Stage.scenes.include? self
      true
    end
  end
end

# frozen_string_literal: true

module FelECS
  module Stage
    class << self
      # Allows clearing of scenes and systems.
      # Used internally by FelECS and shouldn't need to be ever used by developers
      # @!visibility private
      attr_writer :scenes

      # Add any number of Scenes to the Stage
      # @return [Boolean] +true+
      def add(*scenes_to_add)
        self.scenes |= scenes_to_add
        self.scenes = scenes.sort_by(&:priority)
        true
      end

      # Remove any number of Scenes from the Stage
      # @return [Boolean] +true+
      def remove(*scenes_to_remove)
        self.scenes -= scenes_to_remove
        true
      end

      # Clears all Scenes that were added to the Stage
      # @return [Boolean] +true+
      def clear
        self.scenes.clear
        true
      end

      # Executes one frame of the game. This executes all the Scenes added to the Stage in order of their priority.
      # @return [Boolean] +true+
      def call
        self.scenes.each(&:call)
        true
      end

      # Contains all the Scenes added to the Stage
      # @return [Array<Scene>]
      def scenes
        @scenes ||= []
      end
    end
  end
end

# frozen_string_literal: true

module FelECS
  module Order
    # Sets the priority of all items passed into this method
    # according to the order they were passed.
    # If an array is one of the elements then it will give all
    # of those elements in the array the same priority.
    # @param sortables [(Systems and Array<Systems>) or (Scenes and Array<Scenes>)]
    # @return [Boolean] +true+.
    def self.sort(*sortables)
      sortables.each_with_index do |sorted, index|
        if sorted.respond_to? :priority
          sorted.priority = index
        else
          sorted.each do |item|
            item.priority = index
          end
        end
      end
      true
    end
  end
end

# frozen_string_literal: true

# :nocov:
# Keeps the version of the Gem
module FelECS
  # The version of the Gem
  VERSION = '5.0.0'
end
# :nocov:

# frozen_string_literal: true



# The FelECS namespace where all its functionality resides under.
module FelECS
  class << self
    # :nocov:

    # An alias for {FelECS::Stage.call}. It executes a single frame in the game.
    def call
      FelECS::Stage.call
    end
    # :nocov:
  end

  # Creates and manages Entities. Entities are just collections of Components.
  # You can use array methods directly on this class to access Entities.
  class Entities; end

  # Creates component managers and allows accessing them them under the {FelECS::Components} namespace as Constants.
  # You can use array methods directly on this class to access Component Managers.
  #
  # To see how component managers are used please look at the {FelECS::ComponentManager} documentation.
  module Components; end

  # Creates and manages Systems. Systems are the logic of the game and do not contain any data within them. Any systems you create are accessable under the {FelECS::Systems} namespace as Constants.
  # You can use array methods directly on this class to access Systems.
  class Systems; end

  # Creates and manages Scenes. Scenes are collections of Systems, and execute all the Systems when called upon. Any scenes you create are accessable under the {FelECS::Scenes} namespace as Constants.
  class Scenes; end

  # Stores Scenes you add to it which you want to execute on each frame. When called upon will execute all Systems in the Scenes in the Stage and will execute them according to their priority order.
  module Stage; end

  # Sets the priority of a list of Systems or Scenes for you in the order you pass them to this class.
  module Order; end
end

# An alias for {FelECS}
FECS = FelECS

# An alias for {FelECS::Entities}
FECS::Ent = FelECS::Entities

# An alias for {FelECS::Components}
FECS::Cmp = FelECS::Components

# An alias for {FelECS::Systems}
FECS::Sys = FelECS::Systems

# An alias for {FelECS::Scenes}
FECS::Scn = FelECS::Scenes

# An alias for {FelECS::Stage}
FECS::Stg = FelECS::Stage

# An alias for {FelECS::
FECS::Odr = FelECS::Order
