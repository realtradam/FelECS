class Systems
  class UpdateLevels
    @co = Components::Overworld
    def self.run
      @co.data[:add].each do |id|
        @co.data[:add].delete(id)
        if !(Components::Sprite.id & Entity.signatures[id]).zero?
          @co.data[:grid][@co.data[id].x][@co.data[id].y] = {} if @co.data[:grid][@co.data[id].x][@co.data[id].y].nil?
          #@co.data[:grid][@co.data[id].x][@co.data[id].y].merge!({ player: true })
          puts @co.data[:grid][@co.data[id].x][@co.data[id].y].inspect
        elsif !(Components::Map.id & Entity.signatures[id]).zero?
          if Components::Map.data[id].json['tilesets'].last['source'].split('/').last.delete('\\').delete_suffix('.tsx') == 'hitbox'
            Components::Map.data[id].json['layers'].each do |layer|
              layer['chunks'].each do |chunk|
                chunk['data'].each_slice(chunk['width']).with_index do |row, row_index|
                  row.each_with_index do |tile, column_index|
                    if tile.to_i == Components::Map.data[id].json['tilesets'].last['firstgid'].to_i
                      @co.data[:grid][column_index][row_index] = {} if @co.data[:grid][column_index][row_index].nil?
                      @co.data[:grid][column_index][row_index].merge!({ hitbox: true })
                    end
                  end
                end
              end
            end
          end
        end
        puts @co.data[:grid]
      end
      Components::Overworld.data[:remove].each do |id|
        Components::Overworld.data[:remove].delete(id)
      end
    end
  end
end
