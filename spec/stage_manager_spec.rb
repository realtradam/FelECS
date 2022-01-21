# frozen_string_literal: true

require_relative '../lib/felecs'

# class EntitiesTest < Minitest::Test

describe 'Stage' do
  before :all do
    @component_manager ||= FelECS::Components.new('TestStage', order: [])
    @system2 = FelECS::Systems.new('StageTest', priority: 1) do
      @component_manager.first.order.push 2
    end
    @system1 = FelECS::Systems.new('StageMana', priority: 3) do
      @component_manager.first.order.push 1
    end
    @system3 = FelECS::Systems.new('StageSpell', priority: 2) do
      @scene1.add @system1
      @scene2.add @system2
      @scene3.add @system3
      @component_manager.first.order.push 3
    end
    @scene1 = FelECS::Scenes.new('TestStage1', priority: 1)
    @scene2 = FelECS::Scenes.new('TestStage2', priority: 2)
    @scene3 = FelECS::Scenes.new('TestStage3', priority: 3)
  end

  before :each do
    @cmp = @component_manager.new
  end

  after :each do
    FelECS::Entities.reverse_each(&:delete)
    @component_manager.reverse_each(&:delete)
    @scene1.clear
    @scene2.clear
    @scene3.clear
    FelECS::Stage.clear
  end

  it 'can add Scenes' do
    FelECS::Stage.add @scene2, @scene1, @scene3
    expect(FelECS::Stage.scenes).to eq([@scene1, @scene2, @scene3])
  end

  it 'can remove Scenes' do
    FelECS::Stage.add @scene1, @scene2, @scene3
    FelECS::Stage.remove @scene1, @scene3
    expect(FelECS::Stage.scenes).to eq([@scene2])
  end

  it 'can clear Scenes' do
    FelECS::Stage.add @scene1, @scene2, @scene3
    FelECS::Stage.clear
    expect(FelECS::Stage.scenes).to eq([])
  end

  it 'can call Scenes in correct order' do
    FelECS::Stage.add @scene2, @scene1, @scene3
    @scene1.add @system1
    @scene2.add @system2
    @scene3.add @system3
    FelECS::Stage.call
    expect(@component_manager.first.order).to eq([1, 2, 3])
  end
end
