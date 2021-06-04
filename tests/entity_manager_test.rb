require 'minitest/autorun'
require_relative '_test_helper.rb'

require_relative '../felflame.rb'

describe 'Entities' do
  before do
    @one = FelFlame::Entities.new
    @two = FelFlame::Entities.new
    @three = FelFlame::Entities.new
  end

  after do
    FelFlame::Entities.delete(0)
    FelFlame::Entities.delete(1)
    FelFlame::Entities.delete(2)
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
    _(FelFlame::Entities.delete(0)).assert
    _(FelFlame::Entities.get(0)).assert_nil
    _(FelFlame::Entities.delete(7)).refute
  end

  it 'can be dumped' do
    flunk 'need to add dump test'
    @one.dump
  end

  it 'can load dumps' do
    flunk 'need to add this test'
  end
  it 'can have components added' do
    flunk 'make this test'
  end

  it 'can have components removed' do
    flunk 'make this test'
  end
end
