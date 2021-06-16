class FelFlame
  class Systems
    # How early this System should be executed in a list of Systems
    attr_accessor :priority

    # The Constant name assigned to this System
    attr_accessor :const_name

    # How many frames need to pass before this System is executed when controlled by {FelFlame::Stage}
    attr_accessor :frame

    attr_writer :addition_triggers

    def addition_triggers
      @addition_triggers ||= []
    end

    attr_writer :removal_triggers

    def removal_triggers
      @removal_triggers ||= []
    end

    class <<self
      include Enumerable

      # Iterate over all Systems, sorted by their priority. You also call other enumerable methods instead of each, such as +each_with_index+ or +select+
      # @return [Enumerator]
      def each(&block)
        constants.map { |sym| const_get(sym) }.sort_by(&:priority).reverse.each(&block)
      end
    end

    # Creates a new System which can be accessed as a constant under the namespace {FelFlame::Systems}.
    # The name given is what constant the system is assigned to
    #
    # @example
    #   FelFlame::Systems.new('PassiveHeal', priority: -2, frame: 2) do
    #     FelFlame::Components::Health.each do |component|
    #       component.hp += 5
    #     end
    #   end
    #   # Only heal all characters with health every other frame.
    #   # Give it a low priority so other systems such as a
    #   #   Poison system would kill the player first
    #
    # @param name [String] The name this system will use. Needs to to be in the Ruby Constant format.
    # @param priority [Integer] Which priority order this system should be executed in relative to other systems. Higher means executed earlier.
    # @param block [Proc] The code you wish to be executed when the system is triggered. Can be defined by using a +do end+ block or using +{ }+ braces.
    def initialize(name, priority: 0, &block)
      FelFlame::Systems.const_set(name, self)
      @const_name = name
      @priority = priority
      @block = block
    end

    # Manually execute the system a single time
    def call
      @block.call
    end

    # Attempt to execute the system following the frame parameter set on this system.
    # @return [Boolean] +true+ if the frame of the {FelFlame::Stage} is a multiple of this System's frame setting and this system has executed, +false+ otherwise where the system has not executed.
    # For example if a System has its frame set to 3, it will only execute once every third frame that is called in FelFlame::Stage
    #
    def step; end

    # Redefine what code is executed by this System when it is called upon.
    # @param block [Proc] The code you wish to be executed when the system is triggered. Can be defined by using a +do end+ block or using +{ }+ braces.
    def redefine(&block)
      @block = block
    end

    # Removes triggers from this system
    # @param component_or_manager [Component or ComponentManager] The object to clear triggers from. Use Nil to clear triggers from all components associated with this system.
    # @return [Boolean] true
    def clear_triggers(*trigger_types, component_or_manager: nil)
      trigger_types = [:addition_triggers, :removal_triggers] if trigger_types.empty?
      trigger_types.each do |trigger_type|
        if component_or_manager.nil?
          send(trigger_type).each do |trigger|
            trigger.send(trigger_type).delete self
          end
          self.addition_triggers = []
        else
          send(trigger_type).delete component_or_manager
          component_or_manager.send(trigger_type).delete self
        end
      end
      true
    end

    # Add a component or component manager so that it triggers this system when the component or a component from the component manager is added to an entity
    # @param component_or_manager [Component or ComponentManager] The component or component manager to trigger this system when added
    # @return [Boolean] true
    def trigger_when_added(component_or_manager)
      self.addition_triggers |= [component_or_manager]
      component_or_manager.addition_triggers |= [self]
      true
    end

    # Add a component or component manager so that it triggers this system when the component or a component from the component manager is removed from an entity
    # @param component_or_manager [Component or ComponentManager] The component or component manager to trigger this system when removed
    # @return [Boolean] true
    def trigger_when_removed(component_or_manager)
      self.removal_triggers |= [component_or_manager]
      component_or_manager.removal_triggers |= [self]
      true
    end
  end
end
