# frozen_string_literal: true

class Components
  # If an entity can be rendered on screen
  class Interactable < Helper::BaseComponent
    attr_accessor :z

    def initialize
      @z = z
    end

    def set(**opts)
      opts.each do |key, value|
        send "#{key}=", value
      end
    end
  end
end
