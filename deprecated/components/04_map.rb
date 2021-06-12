class Components
  # dragonruby label wrapper
  class Map < Helper::BaseComponent

    attr_accessor :json_name, :json, :x, :y, :tilewidth, :tileheight, :a, :r, :g, :b

    def set(json_name: @json_name, x: @x, y: @y, tilewidth: @tilewidth,
            tileheight: @tileheight, a: @a, r: @r, g: @g, b: @b)
      { json_name: @json_name = json_name,
        json: @json = Helper.get_json_tiles(json_name),
        x: @x = x,
        y: @y = y,
        tilewidth: @tilewidth = tilewidth,
        tileheight: @tileheight = tileheight,
        r: @r = r,
        g: @g = g,
        b: @b = b,
        a: @a = a }
    end
  end
end
