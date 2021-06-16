require_relative '../felflame.rb'

describe 'Components' do

  before :all do
    @component_manager ||= FelFlame::Components.new('TestSystems', health: 10, name: 'imp')
  end

  before :each do
  end

  after :each do
    #TODO: order breaks it
    @component_manager.each(&:delete)
    FelFlame::Entities.each(&:delete)
    FelFlame::Systems.each(&:clear_triggers)
  end

  it 'can create a system' do
    FelFlame::Systems.new('Test100') do
      'Works'
    end
    expect(FelFlame::Systems::Test100.call).to eq('Works')
  end

  it 'can be redefined' do
    FelFlame::Systems.new('Test101') do
      'neat'
    end
    FelFlame::Systems::Test101.redefine do
      'very neat'
    end
    expect(FelFlame::Systems::Test101.call).to eq('very neat')
  end

  it 'can iterate over the sorted systems by priority' do
    FelFlame::Systems.new('Test102', priority: 1) {}
    FelFlame::Systems.new('Test103', priority: 50) {}
    FelFlame::Systems.new('Test104', priority: 7) {}
    answer_key = ['Test103', 'Test104', 'Test102']
    test = FelFlame::Systems.each.to_a
    # converts the system name to the constant, compares their positions making sure they are sorted
    # higher priority should be placed first
    expect(test.map(&:const_name).find_index(answer_key[0])).to be <= test.map(&:const_name).find_index(answer_key[1])
    expect(test.map(&:const_name).find_index(answer_key[0])).to be <= test.map(&:const_name).find_index(answer_key[2])
    expect(test.map(&:const_name).find_index(answer_key[1])).to be >= test.map(&:const_name).find_index(answer_key[0])
    expect(test.map(&:const_name).find_index(answer_key[1])).to be <= test.map(&:const_name).find_index(answer_key[2])
    expect(test.map(&:const_name).find_index(answer_key[2])).to be >= test.map(&:const_name).find_index(answer_key[0])
    expect(test.map(&:const_name).find_index(answer_key[2])).to be >= test.map(&:const_name).find_index(answer_key[1])
  end

  it 'can manipulate components' do
    init1 = 27
    init2 = 130
    multiple = 3
    first = @component_manager.new(health: init1)
    second = @component_manager.new(health: init2)
    FelFlame::Systems.new('Test105') do
      @component_manager.each do |component|
        component.health -= multiple
      end
    end
    FelFlame::Systems::Test105.call
    expect(first.health).to eq(init1 -= multiple)
    expect(second.health).to eq(init2 -= multiple)
    10.times do
      FelFlame::Systems::Test105.call
    end
    expect(first.health).to eq(init1 - (multiple * 10))
    expect(second.health).to eq(init2 - (multiple * 10))
  end
  it 'can trigger when a single Component is added' do
    FelFlame::Systems.new 'Test107' do
      @component_manager.each do |component|
        component.health += 5
      end
    end
    @cmp0 = @component_manager.new
    @cmp1 = @component_manager.new health: 20
    FelFlame::Systems::Test107.trigger_when_added @cmp0
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @entity0 = FelFlame::Entities.new
    @entity1 = FelFlame::Entities.new @cmp0
    expect(@cmp0.health).to eq(15)
    expect(@cmp1.health).to eq(25)
    @entity0.add @cmp0
    expect(@cmp0.health).to eq(20)
    expect(@cmp1.health).to eq(30)
  end

  it 'can trigger when a Component from a manager is added' do
    FelFlame::Systems.new 'Test106' do
      @component_manager.each do |component|
        component.health += 5
      end
    end
    @cmp1 = @component_manager.new
    @cmp2 = @component_manager.new health: 20
    FelFlame::Systems::Test106.trigger_when_added @component_manager
    expect(@cmp1.health).to eq(10)
    expect(@cmp2.health).to eq(20)
    @entity1 = FelFlame::Entities.new
    @entity2 = FelFlame::Entities.new @cmp2
    expect(@cmp1.health).to eq(15)
    expect(@cmp2.health).to eq(25)
    FelFlame::Systems::Test106.trigger_when_added @cmp1
    @entity1.add @cmp1
    expect(@cmp1.health).to eq(20)
    expect(@cmp2.health).to eq(30)
  end

  it 'can trigger when a single Component is removed' do
    FelFlame::Systems.new 'Test108' do
      @component_manager.each do |component|
        component.health += 5
      end
    end
    @cmp0 = @component_manager.new
    @cmp1 = @component_manager.new health: 20
    FelFlame::Systems::Test108.trigger_when_removed @cmp0
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @entity0 = FelFlame::Entities.new
    @entity1 = FelFlame::Entities.new @cmp0
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @entity1.remove @cmp0
    expect(@cmp0.health).to eq(15)
    expect(@cmp1.health).to eq(25)
    @entity0.add @cmp1, @cmp0
    @entity0.remove @cmp1
    expect(@cmp0.health).to eq(15)
    expect(@cmp1.health).to eq(25)
  end

  it 'can trigger when a Component from a manager is removed' do
    FelFlame::Systems.new 'Test109' do
      @component_manager.each do |component|
        component.health += 5
      end
    end
    @cmp0 = @component_manager.new
    @cmp1 = @component_manager.new health: 20
    FelFlame::Systems::Test109.trigger_when_removed @component_manager
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @entity0 = FelFlame::Entities.new
    @entity1 = FelFlame::Entities.new @cmp0
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @entity1.remove @cmp0
    expect(@cmp0.health).to eq(15)
    expect(@cmp1.health).to eq(25)
    FelFlame::Systems::Test109.trigger_when_removed @cmp1
    @entity0.add @cmp1, @cmp0
    @entity0.remove @cmp1
    expect(@cmp0.health).to eq(20)
    expect(@cmp1.health).to eq(30)
  end
=begin
  it 'can trigger when a single Component is added' do
    FelFlame::Systems.new 'Test110' do
      @component_manager.each do |component|
        component.health += 5
      end
    end
    @cmp0 = @component_manager.new
    @cmp1 = @component_manager.new health: 20
    FelFlame::Systems::Test110.trigger_when_is_changed @cmp0, :name
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @entity0 = FelFlame::Entities.new
    @entity1 = FelFlame::Entities.new @cmp0
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @cmp0.name = 'different'
    expect(@cmp0.health).to eq(15)
    expect(@cmp1.health).to eq(25)
    @cmp1.name = 'different'
    expect(@cmp0.health).to eq(15)
    expect(@cmp1.health).to eq(25)
  end
=end
end
