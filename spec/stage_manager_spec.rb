require 'felflame'

#class EntitiesTest < Minitest::Test

describe 'Stage' do
  before :all do
    @component_manager ||= FelFlame::Components.new('TestStage', order: Array.new)
    @system2 = FelFlame::Systems.new('StageTest', priority: 50) do
      @component_manager.each do |component|
        component.order.push 2
      end
    end
    @system1 = FelFlame::Systems.new('StageMana', priority: 1) do
      @component_manager.each do |component|
        component.order.push 1
      end
    end
    @system3 = FelFlame::Systems.new('StageSpell', priority: 100) do
      @component_manager.each do |component|
        component.order.push 3
      end
    end
    @scene1 = FelFlame::Scenes.new('TestStage1')
    @scene2 = FelFlame::Scenes.new('TestStage2')
    @scene3 = FelFlame::Scenes.new('TestStage3')
  end

  before :each do
    @cmp = @component_manager.new
    @scene1.add @system1
    @scene2.add @system2
    @scene3.add @system3
  end

  after :each do
    FelFlame::Entities.each(&:delete)
    @component_manager.each(&:delete)
    @scene1.clear
    @scene2.clear
    @scene3.clear
    FelFlame::Stage.clear
  end

  it 'can add Scenes' do
    FelFlame::Stage.add @scene2, @scene1, @scene3
    expect(FelFlame::Stage.scenes).to eq([@scene2, @scene1, @scene3])
    expect(FelFlame::Stage.systems).to eq([@system1, @system2, @system3])
  end

  it 'can remove Scenes' do
    FelFlame::Stage.add @scene1, @scene2, @scene3
    FelFlame::Stage.remove @scene1, @scene3
    expect(FelFlame::Stage.scenes).to eq([@scene2])
    expect(FelFlame::Stage.systems).to eq([@system2])
  end

  it 'can clear Scenes' do
    FelFlame::Stage.add @scene1, @scene2, @scene3
    FelFlame::Stage.clear
    expect(FelFlame::Stage.scenes).to eq([])
    expect(FelFlame::Stage.systems).to eq([])
  end

  it 'can execute Systems in the correct order' do
    FelFlame::Stage.add @scene2, @scene1, @scene3
    FelFlame::Stage.call
    expect(@cmp.order).to eq([1, 2, 3])
  end

  it 'can add Systems to Scenes already added in Stage' do
    FelFlame::Stage.add @scene2, @scene1, @scene3
    system2p5 = FelFlame::Systems.new('StageAddingTest', priority: 75) do
      @component_manager.each do |component|
        component.order.push 2.5
      end
    end
    @scene2.add system2p5
    @scene3.add system2p5
    FelFlame::Stage.call
    expect(@cmp.order).to eq([1,2,2.5,3])
  end

  it 'can remove Systems to Scenes already added in Stage' do
    FelFlame::Stage.add @scene2, @scene1, @scene3
    system2p5 = FelFlame::Systems.new('StageAddingTest', priority: 75) do
      @component_manager.each do |component|
        component.order.push 2.5
      end
    end
    @scene2.add system2p5
    @scene3.add system2p5
    @scene2.remove @system2
    FelFlame::Stage.call
    expect(@cmp.order).to eq([1,2.5,3])
  end

  it 'can have Systems change priority in an existing Stage' do
    FelFlame::Stage.add @scene2, @scene1, @scene3
    @system2.priority = 0
    FelFlame::Stage.call
    expect(@cmp.order).to eq([2,1,3])
  end
end
