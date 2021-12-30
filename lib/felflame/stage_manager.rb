module FelFlame
  module Stage
    class <<self
      # Allows clearing of scenes and systems.
      # Used internally by FelFlame and shouldn't need to be ever used by developers
      # @!visibility private
      attr_writer :scenes, :systems

      # Add any number of Scenes to the Stage
      # @return [Boolean] +true+
      def add(*scenes_to_add)
        self.scenes |= scenes_to_add
        scenes_to_add.each do |scene|
          self.systems |= scene.systems
        end
        self.systems = systems.sort_by(&:priority)
        true
      end

      # Remove any number of Scenes from the Stage
      # @return [Boolean] +true+
      def remove(*scenes_to_remove)
        self.scenes -= scenes_to_remove
        update_systems_list
        true
      end

      # Updates the list of systems from the Scenes added to the Stage and make sure they are ordered correctly
      # This is used internally by FelFlame and shouldn't need to be ever used by developers
      # @return [Boolean] +true+
      # @!visibility private
      def update_systems_list
        systems.clear
        scenes.each do |scene|
          self.systems |= scene.systems
        end
        self.systems = systems.sort_by(&:priority)
        true
      end

      # Clears all Scenes that were added to the Stage
      # @return [Boolean] +true+
      def clear
        systems.clear
        scenes.clear
        true
      end

      # Executes one frame of the game. This executes all the Systems in the Scenes added to the Stage. Systems that exist in two or more different Scenes will still only get executed once.
      # @return [Boolean] +true+
      def call
        systems.each(&:call)
        true
      end

      # Contains all the Scenes added to the Stage
      # @return [Array<Scene>]
      def scenes
        @scenes ||= []
      end

      # Stores systems in the order the stage manager needs to call them
      # This method should generally only need to be used internally and not by a game developer
      # @!visibility private
      def systems
        @systems ||= []
      end
    end
  end
end
