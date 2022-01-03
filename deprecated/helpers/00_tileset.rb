# frozen_string_literal: true

# Coverage Ignored because the functionality of this
# code will not be used for the core of FelFlame.
# It will most likely be released as a seperate package
# The code will most likely be kept here until it
# eventually will be migrated to a new git repo
# :nocov:
class Helper
  # Returns a loaded map and its dependecies(images,json)
  # If any are missing then it will load them from files

  @json_data = {}
  class << self
    attr_accessor :json_data

    def get_json_tiles(json_name, hitbox: false)
      return nil if !hitbox && (json_name == 'hitbox' && !Components::DebugSingleton.data)

      if json_data[json_name].nil?
        json_data[json_name] = $gtk.parse_json_file "assets/json/#{json_name}.json"
        raise StandardError, "#{json_name} is null and not loaded. Cannot get json tile" if json_data[json_name].nil?

        if json_data[json_name]['type'] == 'map' # json_name.split("_").first == 'map'
          json_data[json_name]['tilesets'].each do |tileset|
            tileset = Helper.get_json_tiles(tileset['source'].split('/').last.delete_suffix('.tsx'))
            # download tileset here
            # $gtk.args.gtk.http_get 'https://mysite.net/#{tileset['name']}.png'
          end
        end
      end
      json_data[json_name]
    end

    def get_tile(json_name:, tile_index:)
      if json_name == 'hitbox' && !Components::DebugSingleton.data
        return tile_index - 1 if tile_index > 1

        return {}
      end

      json_tiles = get_json_tiles(json_name)
      raise StandardError, 'Error, json file not a tileset' unless json_tiles['type'] == 'tileset'
      return tile_index - json_tiles['tilecount'] if tile_index > json_tiles['tilecount']

      source_height_tiles = (tile_index.to_i / json_tiles['columns'].to_i).to_i # * json_tiles['tileheight']
      { w: json_tiles['tilewidth'],
        h: json_tiles['tileheight'],
        path: json_tiles['image'].split('mygame/').last.delete('\\'),
        source_x: [((tile_index % json_tiles['columns']) - 1) * json_tiles['tilewidth'], 0].max,
        # source_y gets special treatment
        source_y: [json_tiles['imageheight'] - ((source_height_tiles + 1) * json_tiles['tileheight']), 0].max,
        source_w: json_tiles['tilewidth'],
        source_h: json_tiles['tileheight'] }
    end
  end
end
# :nocov:
