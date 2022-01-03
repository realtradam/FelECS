module FelFlame
  module Order

    # Sets the priority of all items passed into this method 
    # according to the order they were passed.
    # If an array is one of the elements then it will give all
    # of those elements in the array the same priority.
    # @param sortables [(Systems and Array<Systems>) or (Scenes and Array<Scenes>)] 
    # @return [Boolean] +true+.
    def self.sort(*sortables)
      sortables.each_with_index do |sorted, index|
        if sorted.respond_to? :priority
          sorted.priority = index
        else
          sorted.each do |item|
            item.priority = index
          end
        end
      end
      true
    end
  end
end
