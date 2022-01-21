# frozen_string_literal: true

require_relative 'felecs/entity_manager'
require_relative 'felecs/component_manager'
require_relative 'felecs/system_manager'
require_relative 'felecs/scene_manager'
require_relative 'felecs/stage_manager'
require_relative 'felecs/order'

require_relative 'felecs/version'

# The FelECS namespace where all its functionality resides under.
module FelECS
  class << self
    # :nocov:

    # An alias for {FelECS::Stage.call}. It executes a single frame in the game.
    def call
      FelECS::Stage.call
    end
    # :nocov:
  end

  # Creates and manages Entities. Entities are just collections of Components.
  # You can use array methods directly on this class to access Entities.
  class Entities; end

  # Creates component managers and allows accessing them them under the {FelECS::Components} namespace as Constants.
  # You can use array methods directly on this class to access Component Managers.
  #
  # To see how component managers are used please look at the {FelECS::ComponentManager} documentation.
  module Components; end

  # Creates and manages Systems. Systems are the logic of the game and do not contain any data within them. Any systems you create are accessable under the {FelECS::Systems} namespace as Constants.
  # You can use array methods directly on this class to access Systems.
  class Systems; end

  # Creates and manages Scenes. Scenes are collections of Systems, and execute all the Systems when called upon. Any scenes you create are accessable under the {FelECS::Scenes} namespace as Constants.
  class Scenes; end

  # Stores Scenes you add to it which you want to execute on each frame. When called upon will execute all Systems in the Scenes in the Stage and will execute them according to their priority order.
  module Stage; end

  # Sets the priority of a list of Systems or Scenes for you in the order you pass them to this class.
  module Order; end
end

# An alias for {FelECS}
FECS = FelECS

# An alias for {FelECS::Entities}
FECS::Ent = FelECS::Entities

# An alias for {FelECS::Components}
FECS::Cmp = FelECS::Components

# An alias for {FelECS::Systems}
FECS::Sys = FelECS::Systems

# An alias for {FelECS::Scenes}
FECS::Scn = FelECS::Scenes

# An alias for {FelECS::Stage}
FECS::Stg = FelECS::Stage

# An alias for {FelECS::
FECS::Odr = FelECS::Order
