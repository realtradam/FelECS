class Components
  class Overworld < Helper::Level
    attr_accessor :x, :y

    def initialize
      @x = 0
      @y = 0
    end

    def set(**opts)
      opts.each do |key, value|
        self.send "#{key}=", value
      end
    end
  end
end
