class Systems
  class Render
    def self.run
      Components::Renderable.data.sort_by { |v| v[1].z }.each do |key, data|
        if !(Components::Sprite.id & Entity.signatures[key]).zero?
          $gtk.args.outputs.sprites << Components::Sprite.data[key].set
        elsif !(Components::Label.id & Entity.signatures[key]).zero?
          $gtk.args.outputs.labels << Components::Label.data[key].set
        elsif !(Components::Map.id & Entity.signatures[key]).zero?
          Components::Map.data[key].json['layers'].each do |layer|
            layer['chunks'].each do |chunk|
              chunk['data'].each_slice(chunk['width']).with_index do |row, row_index|
                row.each_with_index do |tile, column_index|
                  unless tile.zero?
                    iter = 0
                    loop do
                      tile = Helper.get_tile(json_name: Components::Map.data[key].json['tilesets'][iter]['source'].split('/').last.delete('\\').delete_suffix('.tsx'), tile_index: tile)
                      break if tile.is_a?(Hash)
                      raise Exception.new "#{Components::Map.data[key].json['json_name']} not valid map, exceeded tile range" if (iter += 1) >= Components::Map.data[key].json['tilesets'].count
                    end
                    unless tile.empty?
                      tile[:x] = Components::Map.data[key].x + (Components::Map.data[key].tilewidth * column_index) + chunk['x']
                      tile[:y] = Components::Map.data[key].y + (Components::Map.data[key].tileheight * row_index) + chunk['y']
                      tile[:w] = Components::Map.data[key].tilewidth
                      tile[:h] = Components::Map.data[key].tileheight
                      $gtk.args.outputs.sprites << tile
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
