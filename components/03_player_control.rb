class Components
  # Gives control(keyboard or otherwise) over an object
  class PlayerControl < Helper::BaseComponent
    attr_accessor :north, :south, :east, :west, :interact, :menu

    def initialize
      @north = 'up'
      @south = 'down'
      @east = 'right'
      @west = 'left'
      @interact = 'space'
      @menu = 'enter'
    end

    def set(**opts)
      opts.each do |key, value|
        send "#{key}=", value
      end
    end
  end
end
