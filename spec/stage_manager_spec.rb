require_relative '../lib/felflame.rb'

#class EntitiesTest < Minitest::Test

describe 'Stage' do
  before :all do
    @component_manager ||= FelFlame::Components.new('TestStage', order: Array.new)
    @system2 = FelFlame::Systems.new('StageTest', priority: 1) do
      @component_manager.first.order.push 2
    end
    @system1 = FelFlame::Systems.new('StageMana', priority: 3) do
      @component_manager.first.order.push 1
    end
    @system3 = FelFlame::Systems.new('StageSpell', priority: 2) do
      @scene1.add @system1
      @scene2.add @system2
      @scene3.add @system3
      @component_manager.first.order.push 3
    end
    @scene1 = FelFlame::Scenes.new('TestStage1', priority: 1)
    @scene2 = FelFlame::Scenes.new('TestStage2', priority: 2)
    @scene3 = FelFlame::Scenes.new('TestStage3', priority: 3)
  end

  before :each do
    @cmp = @component_manager.new
  end

  after :each do
    FelFlame::Entities.reverse_each(&:delete)
    @component_manager.reverse_each(&:delete)
    @scene1.clear
    @scene2.clear
    @scene3.clear
    FelFlame::Stage.clear
  end

  it 'can add Scenes' do
    FelFlame::Stage.add @scene2, @scene1, @scene3
    expect(FelFlame::Stage.scenes).to eq([@scene1, @scene2, @scene3])
  end

  it 'can remove Scenes' do
    FelFlame::Stage.add @scene1, @scene2, @scene3
    FelFlame::Stage.remove @scene1, @scene3
    expect(FelFlame::Stage.scenes).to eq([@scene2])
  end

  it 'can clear Scenes' do
    FelFlame::Stage.add @scene1, @scene2, @scene3
    FelFlame::Stage.clear
    expect(FelFlame::Stage.scenes).to eq([])
  end

  it 'can call Scenes in correct order' do
    FelFlame::Stage.add @scene2, @scene1, @scene3
    @scene1.add @system1
    @scene2.add @system2
    @scene3.add @system3
    FelFlame::Stage.call
    expect(@component_manager.first.order).to eq([1,2,3])
  end

end
