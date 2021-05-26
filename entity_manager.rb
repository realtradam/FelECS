class Entity
  attr_accessor :id

  def initialize(*signature)
    final_signature = 0
    signature.each do |sig|
      final_signature += sig
    end
    @id = Entity.generate_new_id
    self.class.all.push self
    self.class.signatures.push final_signature
    Components.entity_created(@id)
  end

  class <<self
    # All entities that exist
    def all
      @all ||= []
    end

    def id_queue
      @id_queue ||= []
    end

    def generate_new_id
      if id_queue.empty?
        all.size
      else
        id_queue.shift
      end
    end

    # What components a given entity uses
    def signatures
      @signatures ||= []
    end

    def destroy_entity(entity_id)
      if all[entity_id].nil?
        puts 'Entity can not be destroyed, id out of bounds'
      elsif entity_id < all.size - 1
        Components.constants.each do |constant|
          unless (signatures[entity_id] & Components::const_get(constant).id).zero?
            Components::const_get(constant).delete(entity_id)
          end
        end
        all[entity_id] = nil
        signatures[entity_id] = nil
        id_queue.push entity_id
      elsif entity_id == all.size - 1
        Components.constants.each do |constant|
          unless (signatures[entity_id] & Components::const_get(constant).id).zero?
            Components::const_get(constant).delete(entity_id)
          end
        end
        all.pop
        signatures.pop
      else
        puts 'Unknown error with destroy_entity, entity not destroyed'
      end
    end
  end
end
