class Components
  # A dragonruby label wrapper
  class Label < Helper::BaseComponent

    attr_accessor :x, :y, :text, :size_enum, :alignment_enum,
      :a, :r, :g, :b, :font, :vertical_alignment_enum

    def set(x: @x, y: @y, text: @text, size_enum: @size_enum, alignment_enum: @alignment_enum,
            a: @a, r: @r, g: @g, b: @b, font: @font, vertical_alignment_enum: @vertical_alignment_enum)
      {x: @x = x,
       y: @y = y,
       text: @text = text,
       size_enum: @size_enum = size_enum,
       alignment_enum: @alignment_enum = alignment_enum,
       r: @r = r,
       g: @g = g,
       b: @b = b,
       a: @a = a,
       font: @font = font,
       vertical_alignment_enum: @vertical_alignment_enum = vertical_alignment_enum }
    end

    def primative_marker
      :label
    end
  end
end
