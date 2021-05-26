class ID
  class <<self
    @next_id = 0b0_010_000_000_000

    def create_new_id(name)
      temp = @next_id
      @next_id *= 2
      define_singleton_method(name) do
        temp
      end
      send(name)
    end

    def renderable
      0b0_001
    end

    def sprite
      0b0_010
    end

    def label
      0b0_100
    end

    def player_control
      0b0_001_000
    end

    def map
      0b0_010_000
    end

    def interactable
      0b0_100_000
    end

    def collidable
      0b0_001_000_000
    end

    def overworld
      0b0_010_000_000
    end

    def indoor
      0b0_100_000_000
    end

    def battle
      0b0_001_000_000_000
    end
  end
end
