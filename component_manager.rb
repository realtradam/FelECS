#require 'app/ECS/base_component.rb'

#require 'app/ECS/components/00_test_component.rb'
#require 'app/ECS/components/01_based.rb'
class FelFlame
  class Components
    @component_map = []
    class <<self
      def entity_destroyed(entity_id)
        #TODO: make it 'search by entity' to remove
        @component_map.delete(entity_id)
        constants.each do |component| #TODO: change delete to remove
          component.delete(entity_id) unless (component.signature & FelFlame::Entity.signatures[entity_id]).zero?
        end
      end

      #def entity_created(entity_id)
      #  #TODO: probably delete this, I dont think its needed in the new system
      #  constants.each do |component|
      #    const_get(component.to_s).add(entity_id) unless (const_get(component.to_s).signature & FelFlame::Entity.signatures[entity_id]).zero?
      #  end
      #  @component_map[entity_id] = []
      #end

      def new(component_name, *attrs, **attrs_with_defaults)
        const_set(component_name, Class.new(FelFlame::Helper::BaseComponent) {})
        attrs.each do |attr|
          FelFlame::Components.const_get(component_name).attr_accessor attr
        end
        attrs_with_defaults.each do |attr, _default|
          FelFlame::Components.const_get(component_name).attr_accessor attr
        end
        FelFlame::Components.const_get(component_name).define_method(:initialize) do
          attrs_with_defaults.each do |attr, default|
            instance_variable_set("@#{attr}", default)
          end
        end
      end
    end
  end
end
