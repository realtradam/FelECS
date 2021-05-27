require 'minitest/autorun'
require_relative '_test_helper.rb'

require_relative '../entity_manager.rb'

describe 'Entities' do
  before do
    @one = FelFlame::Entities.new
    @two = FelFlame::Entities.new
    @three = FelFlame::Entities.new
  end

  it 'has correct ID\'s' do
    _(@one.id).must_equal 0
    _(@two.id).must_equal 1
    _(@three.id).must_equal 2
  end

  it 'can be accessed' do
    _(@one).must_equal FelFlame::Entities.get(0)
    _(@two).must_equal FelFlame::Entities.get(1)
    _(@three).must_equal FelFlame::Entities.get(2)
  end

  it 'can be deleted' do
    FelFlame::Entities.delete(0)
    _(FelFlame::Entities.get(0)).assert_nil
  end

  it 'can be dumped' do
    flunk('need to add dump test')
    @one.dump
  end
end
