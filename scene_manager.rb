class FelFlame
  class Scenes
    # The Constant name assigned to this Scene
    attr_reader :const_name

    attr_writer :systems

    # Create a new Scene using the name given
    # @param name [String] String format must follow requirements of a constant
    def initialize(name)
      FelFlame::Scenes.const_set(name, self)
      @const_name = name
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
      systems.sort_by!(&:priority)
      FelFlame::Stage.update_systems_list if FelFlame::Stage.scenes.include? self
      true
    end

    # Removes any number of SystemS from this Scene
    # @return [Boolean] +true+
    def remove(*systems_to_remove)
      self.systems -= systems_to_remove
      systems.sort_by!(&:priority)
      FelFlame::Stage.update_systems_list if FelFlame::Stage.scenes.include? self
      true
    end

    # Removes all Systems from this Scene
    # @return [Boolean] +true+
    def clear
      systems.clear
      FelFlame::Stage.update_systems_list if FelFlame::Stage.scenes.include? self
      true
    end
  end
end
