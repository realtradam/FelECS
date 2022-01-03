# frozen_string_literal: true

class Components
  # If an entity can be rendered on screen
  class Collidable < Helper::BaseComponent
    class << self
    end
    attr_accessor :grid

    def initialize
      @grid = [[]]
    end

    def set(**opts)
      opts.each do |key, value|
        send "#{key}=", value
      end
    end
  end
end
