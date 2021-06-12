class Components
  # If an entity can be rendered on screen
  class Collidable < Helper::BaseComponent
    class <<self
      def add(entity_id)
        super(entity_id)
        #add to grid?
      end
    end
    attr_accessor :grid

    def initialize
      @grid = [[]]
    end

    def set(**opts)
      opts.each do |key, value|
        self.send "#{key}=", value
      end
    end
  end
end
