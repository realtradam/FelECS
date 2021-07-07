require_relative './entity_manager'
require_relative './component_manager'
require_relative './system_manager'
require_relative './scene_manager'
require_relative './stage_manager'

# The FelFlame namespace where all its functionality resides under.
class FelFlame
  class <<self
    # :nocov:

    # An alias for {FelFlame::Stage.call}. It executes a single frame in the game.
    def call
      FelFlame::Stage.call
    end
    # :nocov:
  end

  # Creates and manages Entities. Allows accessing Entities using their {FelFlame::Entities#id ID}. Entities are just collections of Components.
  class Entities; end

  # Creates component managers and allows accessing them them under the {FelFlame::Components} namespace as Constants
  #
  # To see how component managers are used please look at the {FelFlame::ComponentManager} documentation.
  class Components; end

  # Creates an manages Systems. Systems are the logic of the game and do not contain any data within them.
  #
  # TODO: Improve Systems overview
  class Systems; end

  # Creates and manages Scenes. Scenes are collections of Systems, and execute all the Systems when called upon.
  # 
  # TODO: Improve Scenes overview
  class Scenes; end

  # Stores Scenes which you want to execute on each frame. When called upon will execute all Systems in the Scenes in the Stage and will execute them according to their priority order.
  class Stage; end
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
FF::Sce = FelFlame::Scenes

# An alias for {FelFlame::Stage}
FF::Stg = FelFlame::Stage
