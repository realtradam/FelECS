require 'minitest/autorun'
require_relative '_test_helper.rb'

require_relative '../felflame.rb'

describe 'Components' do
  before(:all) do
    FelFlame::Components.new('Test', :param1, param2: 'default')
    #setup vars here
  end

  after do
    FelFlame::Components::Test.each.delete
  end

  it 'can create new component types' do
    _(FelFlame::Components.new('Test2', :p, k: 'something')).must_equal\
      FelFlame::Components::Test2
  end

  it 'can make new components' do
    _(FelFlame::Components::Test.new).must_equal FelFlame::Components::Test.get(0)
  end

  it 'can set values' do
    test = FelFlame::Components::Test.new
    _(test.param1 = 'ok').must_equal 'ok'
    _(test.param1).must_equal 'ok'
  end

  it 'can add to entity' do
    flunk
  end

  it 'can remove from entity' do
    flunk
  end

  it 'can delete component' do
    flunk
  end

  it 'can dump single component' do
    flunk
  end

  it 'can load single component' do
    flunk
  end

  it 'can be added as \'when added\' trigger to system' do
    flunk
  end

  it 'can be added as \'when removed\' trigger to system' do
    flunk
  end

  it 'can be added as \'when is_set\' trigger to system' do
    flunk
  end
end
