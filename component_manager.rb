#require 'app/ECS/base_component.rb'

#require 'app/ECS/components/00_test_component.rb'
#require 'app/ECS/components/01_based.rb'

class Components
  class <<self
    def entity_destroyed(entity_id)
      constants.each do |component|
        component.delete(entity_id) unless (component.id & Entity.signatures[entity_id]).zero?
      end
    end

    def entity_created(entity_id)
      constants.each do |component|
        const_get(component.to_s).add(entity_id) unless (const_get(component.to_s).id & Entity.signatures[entity_id]).zero?
      end
    end

    def new(component_name, *attrs, **attrs_with_defaults)
      const_set(component_name, Class.new(Helper::BaseComponent) {})
      attrs.each do |attr|
        Components.const_get(component_name).attr_accessor attr
      end
      attrs_with_defaults.each do |attr, default|
        Components.const_get(component_name).attr_writer attr
        Components.const_get(component_name).define_method(attr) do
          return default unless instance_variable_defined? "@#{attr}"

          instance_variable_get "@#{attr}"
        end
      end
    end
  end
end
