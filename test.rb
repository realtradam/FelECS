require_relative './entity_manager.rb'
require_relative './component_manager.rb'
require_relative './system_manager.rb'

move = '0001'.to_i(2)
base = '0010'.to_i(2)
both = '0011'.to_i(2)
Entity.new(move)
Entity.new(base)
Entity.new(both)

3.times do
  Systems.constants.each do |constant|
    puts "|----#{constant.to_s.upcase}----|"
    Systems::const_get(constant).run
  end
  #ECS::Entity.destroy_entity(ECS::Entity.all.last.id) unless ECS::Entity.all.empty?
end
