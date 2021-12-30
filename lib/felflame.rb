require_relative 'felflame/entity_manager'
require_relative 'felflame/component_manager'
require_relative 'felflame/system_manager'
require_relative 'felflame/scene_manager'
require_relative 'felflame/stage_manager'

require_relative 'felflame/version'

# The FelFlame namespace where all its functionality resides under.
module FelFlame
  class <<self
    # :nocov:

    # An alias for {FelFlame::Stage.call}. It executes a single frame in the game.
    def call
      FelFlame::Stage.call
    end
    # :nocov:
  end

  # Creates and manages Entities. Allows iterating or accessing Entities using array methods directly on the class. Entities are just collections of Components.
  class Entities; end

  # Creates component managers and allows accessing them them under the {FelFlame::Components} namespace as Constants.
  #
  # To see how component managers are used please look at the {FelFlame::ComponentManager} documentation.
  module Components; end

  # Creates an manages Systems. Systems are the logic of the game and do not contain any data within them. Any systems you create are accessable under the {FelFlame::Systems} namespace as Constants.
  #
  # TODO: Improve Systems overview
  class Systems; end

  # Creates and manages Scenes. Scenes are collections of Systems, and execute all the Systems when called upon. Any scenes you create are accessable under the {FelFlame::Scenes} namespace as Constants.
  # 
  # TODO: Improve Scenes overview
  class Scenes; end

  # Stores Scenes you add to it which you want to execute on each frame. When called upon will execute all Systems in the Scenes in the Stage and will execute them according to their priority order.
  module Stage; end
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
FF::Scn = FelFlame::Scenes

# An alias for {FelFlame::Stage}
FF::Stg = FelFlame::Stage
