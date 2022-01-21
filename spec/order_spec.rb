# frozen_string_literal: true

require_relative '../lib/felecs'

# class EntitiesTest < Minitest::Test

describe 'Order' do
  before :all do
    @result = []
    @system0 = FelECS::Systems.new('System1', priority: 0) do
      @result.push 0
    end
    @system2 = FelECS::Systems.new('System3', priority: 2) do
      @result.push 2
    end
    @system1 = FelECS::Systems.new('System2', priority: 1) do
      @result.push 1
    end

    @scene1 = FelECS::Scenes.new('Scene0', priority: 1)
    @scene0 = FelECS::Scenes.new('Scene0', priority: 0)
  end

  before :each do
  end

  after :each do
    @result.clear
    @scene0.clear
    @scene1.clear
    @system0.priority = 0
    @system1.priority = 1
    @system2.priority = 2
    @scene0.priority = 0
    @scene1.priority = 1
  end

  it 'can sort Scenes' do
    @scene0.add @system0
    @scene1.add @system1
    FelECS::Order.sort(
      @scene1,
      @scene0
    )
    expect(@scene1.priority < @scene0.priority).to eq(true)
  end

  it 'can sort Systems' do
    @scene0.add @system0, @system1, @system2
    FelECS::Order.sort(
      @system2,
      @system0,
      @system1
    )
    @scene0.call
    expect(@result).to eq([2, 0, 1])
  end

  it 'can handle array' do
    FelECS::Order.sort(
      @system0,
      [
        @system1,
        @system2
      ]
    )
    expect(@system0.priority < @system1.priority).to eq(true)
    expect(@system0.priority < @system2.priority).to eq(true)
    expect(@system1.priority == @system2.priority).to eq(true)
  end
end
