require_relative '../lib/felflame.rb'

#class EntitiesTest < Minitest::Test

describe 'Scenes' do
  before :all do
    @component_manager ||= FelFlame::Components.new('TestScenes', order: [])
    @system2 = FelFlame::Systems.new('Test', priority: 2) do
      @component_manager.each do |component|
        component.order.push 2
      end
    end
    @system1 = FelFlame::Systems.new('Mana', priority: 1) do
      @component_manager.each do |component|
        component.order.push 1
      end
    end
    @system3 = FelFlame::Systems.new('Spell', priority: 3) do
      @component_manager.each do |component|
        component.order.push 3
      end
    end
    @scene = FelFlame::Scenes.new('TestScene')
  end

  before :each do
    @cmp = @component_manager.new
  end

  after :each do
    FelFlame::Entities.each(&:delete)
    @component_manager.each(&:delete)
    @scene.clear
  end

  it 'can add Systems' do
    @scene.add @system2, @system3, @system1
    expect(@system1.scenes.length).to eq(1)
    expect(@system2.scenes.length).to eq(1)
    expect(@system3.scenes.length).to eq(1)
    expect(@scene.systems).to eq([@system1, @system2, @system3])
  end

  it 'can remove Systems' do
    @scene.add @system2, @system3, @system1
    @scene.remove @system2, @system3
    expect(@scene.systems).to eq([@system1])
  end

  it 'can clear Systems' do
    @scene.add @system2, @system3, @system1
    @scene.clear
    expect(@system1.scenes.length).to eq(0)
    expect(@system2.scenes.length).to eq(0)
    expect(@system3.scenes.length).to eq(0)
    expect(@scene.systems).to eq([])
  end

  it 'can execute Systems in the correct order' do
    @scene.add @system2, @system3, @system1
    @scene.call
    expect(@cmp.order).to eq([1, 2, 3])
    @cmp.order = []
    @system3.priority = -1
    @scene.call
    expect(@cmp.order).to eq([3, 1, 2])
  end
end
