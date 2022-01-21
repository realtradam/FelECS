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
