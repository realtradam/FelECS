require 'felflame'

describe 'Components' do

  before :all do
    @component_manager ||= FelFlame::Components.new('TestSystems', health: 10, whatever: 'imp', mana: 10)
    @@testitr = 999
  end

  before :each do
    @@testitr += 1
    @system = FelFlame::Systems.new "Test#{@@testitr}" do
      @component_manager.each do |component|
        component.health += 5
      end
    end
  end

  after :each do
    @component_manager.each(&:delete)
    FelFlame::Entities.each(&:delete)
    FelFlame::Systems.each(&:clear_triggers)
  end

  it 'can create a system' do
    FelFlame::Systems.new('Test99') do
      'Works'
    end
    expect(FelFlame::Systems::Test99.call).to eq('Works')
  end

  it 'can be redefined' do
    @system.redefine do
      'very neat'
    end
    expect(@system.call).to eq('very neat')
  end

  it 'can iterate over the sorted systems by priority' do
    FelFlame::Systems.new('Test2', priority: 1) {}
    FelFlame::Systems.new('Test3', priority: 50) {}
    FelFlame::Systems.new('Test4', priority: 7) {}
    answer_key = ['Test3', 'Test4', 'Test2']
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
    @system.redefine do
      @component_manager.each do |component|
        component.health -= multiple
      end
    end
    @system.call
    expect(first.health).to eq(init1 -= multiple)
    expect(second.health).to eq(init2 -= multiple)
    10.times do
      @system.call
    end
    expect(first.health).to eq(init1 - (multiple * 10))
    expect(second.health).to eq(init2 - (multiple * 10))
  end

  it 'can trigger when a single Component is added' do
    @cmp0 = @component_manager.new
    @cmp1 = @component_manager.new health: 20
    @system.trigger_when_added @cmp0
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
    @cmp1 = @component_manager.new
    @cmp2 = @component_manager.new health: 20
    @system.trigger_when_added @component_manager
    expect(@cmp1.health).to eq(10)
    expect(@cmp2.health).to eq(20)
    @entity1 = FelFlame::Entities.new
    @entity2 = FelFlame::Entities.new @cmp2
    expect(@cmp1.health).to eq(15)
    expect(@cmp2.health).to eq(25)
    @system.trigger_when_added @cmp1
    @entity1.add @cmp1
    expect(@cmp1.health).to eq(20)
    expect(@cmp2.health).to eq(30)
  end

  it 'can trigger when a single Component is removed' do
    @cmp0 = @component_manager.new
    @cmp1 = @component_manager.new health: 20
    @system.trigger_when_removed @cmp0
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
    @system.clear_triggers(:removal_triggers, component_or_manager: @cmp0)
    @entity1.add @cmp0
    @entity1.remove @cmp0
    expect(@cmp0.health).to eq(15)
    expect(@cmp1.health).to eq(25)
  end

  it 'can trigger when a Component from a manager is removed' do
    @cmp0 = @component_manager.new
    @cmp1 = @component_manager.new health: 20
    @system.trigger_when_removed @component_manager
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @entity0 = FelFlame::Entities.new
    @entity1 = FelFlame::Entities.new @cmp0
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @entity1.remove @cmp0
    expect(@cmp0.health).to eq(15)
    expect(@cmp1.health).to eq(25)
    @system.trigger_when_removed @cmp1
    @entity0.add @cmp1, @cmp0
    @entity0.remove @cmp1
    expect(@cmp0.health).to eq(20)
    expect(@cmp1.health).to eq(30)
    @system.clear_triggers(:removal_triggers)
    @entity1.add @cmp0, @cmp1
    @entity1.remove @cmp0, @cmp1
    expect(@cmp0.health).to eq(20)
    expect(@cmp1.health).to eq(30)
  end

  it 'can trigger when a single Component\'s attribute is changed' do
    @cmp0 = @component_manager.new
    @cmp1 = @component_manager.new health: 20
    @system.trigger_when_is_changed @cmp0, :whatever
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @entity0 = FelFlame::Entities.new
    @entity1 = FelFlame::Entities.new @cmp0
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @cmp0.whatever = 'different'
    expect(@cmp0.health).to eq(15)
    expect(@cmp1.health).to eq(25)
    @cmp1.whatever = 'different'
    expect(@cmp0.health).to eq(15)
    expect(@cmp1.health).to eq(25)
  end

  it 'can clear all triggers' do
    @cmp0 = @component_manager.new health: 10
    @cmp1 = @component_manager.new health: 20
    @entity1 = FelFlame::Entities.new
    @system.trigger_when_added @cmp0
    @system.trigger_when_added @component_manager
    @system.trigger_when_removed @cmp0
    @system.trigger_when_removed @component_manager
    @system.trigger_when_is_changed @cmp0, :whatever
    @system.trigger_when_is_changed @component_manager, :whatever
    @system.clear_triggers
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @entity1.add @cmp0, @cmp1
    @entity1.remove @cmp0, @cmp1
    @cmp0.whatever = 'something'
    @cmp1.whatever = 'different'
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
  end

  it 'can clear individual attr_triggers, without component or manager' do
    @cmp0 = @component_manager.new health: 10, mana: 10
    @cmp1 = @component_manager.new health: 20, mana: 20
    @entity1 = FelFlame::Entities.new
    @system.trigger_when_is_changed @cmp0, :whatever
    @system.trigger_when_is_changed @component_manager, :whatever
    @system.trigger_when_is_changed @cmp0, :mana
    @system.trigger_when_is_changed @component_manager, :mana
    @system.clear_triggers :attr_triggers, :whatever
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @cmp0.whatever = 'something'
    @cmp1.whatever = 'different'
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @cmp0.mana = 15
    @cmp1.mana = 15
    expect(@cmp0.health).to eq(20)
    expect(@cmp1.health).to eq(30)
  end

  it 'can clear individual attr_triggers, with component' do
    @cmp0 = @component_manager.new health: 10, mana: 10
    @cmp1 = @component_manager.new health: 20, mana: 20
    @entity1 = FelFlame::Entities.new
    @system.trigger_when_is_changed @cmp0, :whatever
    @system.trigger_when_is_changed @cmp0, :mana
    #expect(@system.attr_triggers).to eq({@cmp0 => [:name, :mana]})
    #expect(@cmp0.attr_triggers).to eq({:name => [@system], :mana => [@system]})
    @system.clear_triggers :attr_triggers, :whatever, component_or_manager: @cmp0
    #expect(@system.attr_triggers).to eq({@cmp0 => [:mana]})
    #expect(@cmp0.attr_triggers).to eq({:name => [], :mana => [@system]})
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @cmp0.whatever = 'something'
    @cmp1.whatever = 'different'
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @cmp0.mana = 15
    @cmp1.mana = 15
    expect(@cmp0.health).to eq(15)
    expect(@cmp1.health).to eq(25)
  end

  it 'can clear individual attr_triggers, with manager' do
    @cmp0 = @component_manager.new health: 10, mana: 10
    @cmp1 = @component_manager.new health: 20, mana: 20
    @entity1 = FelFlame::Entities.new
    @system.trigger_when_is_changed @component_manager, :whatever
    @system.trigger_when_is_changed @component_manager, :mana
    @system.clear_triggers :attr_triggers, :whatever, component_or_manager: @component_manager
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @cmp0.whatever = 'something'
    @cmp1.whatever = 'different'
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @cmp0.mana = 15
    @cmp1.mana = 15
    expect(@cmp0.health).to eq(20)
    expect(@cmp1.health).to eq(30)
  end

  it 'can clear all attr_triggers, without component or manager' do
    @cmp0 = @component_manager.new health: 10, mana: 10
    @cmp1 = @component_manager.new health: 20, mana: 20
    @entity1 = FelFlame::Entities.new
    @system.trigger_when_is_changed @component_manager, :whatever
    @system.trigger_when_is_changed @cmp1, :mana
    @system.clear_triggers :attr_triggers
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @cmp0.whatever = 'something'
    @cmp1.whatever = 'different'
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @cmp0.mana = 15
    @cmp1.mana = 15
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
  end

  it 'can clear all attr_triggers, with component' do
    @cmp0 = @component_manager.new health: 10, mana: 10
    @cmp1 = @component_manager.new health: 20, mana: 20
    @entity1 = FelFlame::Entities.new
    @system.trigger_when_is_changed @component_manager, :whatever
    @system.trigger_when_is_changed @cmp1, :mana
    @system.clear_triggers :attr_triggers, component_or_manager: @cmp1
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @cmp0.whatever = 'something'
    @cmp1.whatever = 'different'
    expect(@cmp0.health).to eq(20)
    expect(@cmp1.health).to eq(30)
    @cmp0.mana = 15
    @cmp1.mana = 15
    expect(@cmp0.health).to eq(20)
    expect(@cmp1.health).to eq(30)
  end

  it 'can clear all attr_triggers, with manager' do
    @cmp0 = @component_manager.new health: 10, mana: 10
    @cmp1 = @component_manager.new health: 20, mana: 20
    @entity1 = FelFlame::Entities.new
    @system.trigger_when_is_changed @component_manager, :whatever
    @system.trigger_when_is_changed @cmp1, :mana
    @system.clear_triggers :attr_triggers, component_or_manager: @component_manager
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @cmp0.whatever = 'something'
    @cmp1.whatever = 'different'
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @cmp0.mana = 15
    @cmp1.mana = 15
    expect(@cmp0.health).to eq(15)
    expect(@cmp1.health).to eq(25)
  end

  it 'can clear addition_trigger, without component or manager' do
    @cmp0 = @component_manager.new health: 10
    @cmp1 = @component_manager.new health: 20
    @entity1 = FelFlame::Entities.new
    @system.trigger_when_added @cmp0
    @system.trigger_when_added @component_manager
    @system.clear_triggers(:addition_triggers)
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @entity1.add @cmp0, @cmp1
    @entity1.remove @cmp0, @cmp1
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
  end
  
  it 'can clear addition_trigger, with component' do
    @cmp0 = @component_manager.new health: 10
    @cmp1 = @component_manager.new health: 20
    @entity1 = FelFlame::Entities.new
    @system.trigger_when_added @cmp0
    @system.clear_triggers :addition_triggers, component_or_manager: @cmp0
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @entity1.add @cmp0, @cmp1
    @entity1.remove @cmp0, @cmp1
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
  end

  it 'can clear addition_trigger, with manager' do
    @cmp0 = @component_manager.new health: 10
    @cmp1 = @component_manager.new health: 20
    @entity1 = FelFlame::Entities.new
    @system.trigger_when_added @component_manager
    @system.clear_triggers :addition_triggers, component_or_manager: @component_manager
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @entity1.add @cmp0, @cmp1
    @entity1.remove @cmp0, @cmp1
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
  end

  it 'can clear removal_trigger, without component or manager' do
    @cmp0 = @component_manager.new health: 10
    @cmp1 = @component_manager.new health: 20
    @entity1 = FelFlame::Entities.new
    @system.trigger_when_removed @cmp0
    @system.trigger_when_removed @component_manager
    @system.clear_triggers(:removal_triggers)
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @entity1.add @cmp0, @cmp1
    @entity1.remove @cmp0, @cmp1
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
  end
  
  it 'can clear removal_trigger, with component' do
    @cmp0 = @component_manager.new health: 10
    @cmp1 = @component_manager.new health: 20
    @entity1 = FelFlame::Entities.new
    @system.trigger_when_removed @cmp0
    @system.clear_triggers :removal_triggers, component_or_manager: @cmp0
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @entity1.add @cmp0, @cmp1
    @entity1.remove @cmp0, @cmp1
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
  end

  it 'can clear removal_trigger, with manager' do
    @cmp0 = @component_manager.new health: 10
    @cmp1 = @component_manager.new health: 20
    @entity1 = FelFlame::Entities.new
    @system.trigger_when_removed @component_manager
    @system.clear_triggers :removal_triggers, component_or_manager: @component_manager
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
    @entity1.add @cmp0, @cmp1
    @entity1.remove @cmp0, @cmp1
    expect(@cmp0.health).to eq(10)
    expect(@cmp1.health).to eq(20)
  end
end
