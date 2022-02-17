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
