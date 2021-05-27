require_relative './entity_manager.rb'
require_relative './component_manager.rb'
require_relative './system_manager.rb'
require_relative './scene_manager.rb'
require_relative './stage_manager.rb'

class FelFlame
  class <<self
    def dump
    end

    def load
    end

    def Ent
      FelFlame::Entities
    end

    def Cmp
      FelFlame::Components
    end

    def Sys
      FelFlame::Systems
    end

    def Scn
      FelFlame::Scene
    end

    def Stg
      FelFlame::Stage
    end

    def const_missing(name)
      FelFlame.send name.to_s
    end

    def method_missing(name)
      if name[0] == name[0].upcase
        # TODO throw NameError
        super
      else
        super
      end
    end
  end
end

FF = FelFlame # TODO Maybe find better solution?

