class Systems
  class Player
    @co = Components::Overworld
    def self.run
      Components::PlayerControl.data.each do |id, data|
        puts6 "Right: #{@co.data[:grid][@co.data[id].x+1][@co.data[id].y]}"
        puts6 "Left #{@co.data[:grid][@co.data[id].x-1][@co.data[id].y]}"
        puts6 "Down #{@co.data[:grid][@co.data[id].x][@co.data[id].y+1]}"
        puts6 "Up #{@co.data[:grid][@co.data[id].x][@co.data[id].y-1]}"
        #puts6 @co.data[:grid][@co.data[id].x + 1][@co.data[id].y][:hitbox].nil?

        if !(Components::Sprite.id & Entity.signatures[id]).zero?
          if $gtk.args.inputs.keyboard.key_down.send(data.north) &&\
              (@co.data[:grid][@co.data[id].x][@co.data[id].y - 1].nil? ||\
              @co.data[:grid][@co.data[id].x][@co.data[id].y - 1][:hitbox].nil?)
            Components::Sprite.data[id].y -= 64
            @co.data[id].y -= 1
          elsif $gtk.args.inputs.keyboard.key_down.send(data.south) &&\
            (@co.data[:grid][@co.data[id].x][@co.data[id].y + 1].nil? ||\
            @co.data[:grid][@co.data[id].x][@co.data[id].y + 1][:hitbox].nil?)
            Components::Sprite.data[id].y += 64
            @co.data[id].y += 1
          elsif $gtk.args.inputs.keyboard.key_down.send(data.east) &&\
            (@co.data[:grid][@co.data[id].x + 1][@co.data[id].y].nil? ||\
            @co.data[:grid][@co.data[id].x + 1][@co.data[id].y][:hitbox].nil?)
            Components::Sprite.data[id].x += 64
            @co.data[id].x += 1
          elsif $gtk.args.inputs.keyboard.key_down.send(data.west) &&\
            (@co.data[:grid][@co.data[id].x - 1][@co.data[id].y].nil? || @co.data[:grid][@co.data[id].x - 1][@co.data[id].y][:hitbox].nil?)
            Components::Sprite.data[id].x -= 64
            @co.data[id].x -= 1
          end
          #Components::Sprite.data[id].y -= 64 if $gtk.args.inputs.keyboard.key_down.send(data.north)
          #Components::Sprite.data[id].y += 64 if $gtk.args.inputs.keyboard.key_down.send(data.south)
          #Components::Sprite.data[id].x += 64 if $gtk.args.inputs.keyboard.key_down.send(data.east)
          #Components::Sprite.data[id].x -= 64 if $gtk.args.inputs.keyboard.key_down.send(data.west)
        end
      end
    end
  end
end
