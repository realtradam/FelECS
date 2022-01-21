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
