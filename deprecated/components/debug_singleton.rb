class Components
  # If an entity can be rendered on screen
  class DebugSingleton
    class <<self
      @data = false
      attr_accessor :data

      def id
        0
      end
    end
  end
end
