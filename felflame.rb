require_relative './entity_manager.rb'
require_relative './component_manager.rb'
require_relative './system_manager.rb'
require_relative './scene_manager.rb'
require_relative './stage_manager.rb'

class FelFlame
  # Creates and manages Entities. Allows accessing Entities using their {FelFlame::Entities#id ID}
  #
  # TODO: Improve Entity overview
  class Entities; end

  # Creates component managers and allows accessing them them under the {FelFlame::Components} namespace as Constants
  #
  # To see how component managers are used please look at the {FelFlame::Helper::ComponentManagerTemplate} documentation.
  #
  # TODO: Improve Component overview
  class Components; end

  # Creates an manages Systems.
  #
  # TODO: Improve System overview
  class Systems; end
end

# An alias for {FelFlame}
FF = FelFlame

# An alias for {FelFlame::Entities}
FF::Ent = FelFlame::Entities

# An alias for {FelFlame::Components}
FF::Cmp = FelFlame::Components

# An alias for {FelFlame::Systems}
FF::Sys = FelFlame::Systems

# An alias for {FelFlame::Scenes}
#FF::Sce = FelFlame::Scenes
#
# An alias for {FelFlame::Stage}
#FF::Stg = FelFlame::Stage
