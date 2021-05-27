require 'minitest/autorun'
require_relative '_test_helper.rb'

require_relative '../entity_manager.rb'

describe 'Entities' do
  before do
    @one = FelFlame::Entities.new
    @two = FelFlame::Entities.new
    @three = FelFlame::Entities.new
  end

  it 'Has correct ID\'s' do
    _(@one.id).must_equal 0
    _(@two.id).must_equal 1
    _(@three.id).must_equal 2
  end
end
