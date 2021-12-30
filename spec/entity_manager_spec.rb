require_relative '../lib/felflame.rb'

#class EntitiesTest < Minitest::Test

describe 'Entities' do

  #let :component_manager do
  #  @component_manager ||= FelFlame::Components.new('Test', :param1, param2: 'def')
  #end

  before :all do
    $VERBOSE = nil
    @component_manager ||= FelFlame::Components.new('TestEntity', :param1, param2: 'def')
  end


  before :each do
    @orig_stderr = $stderr
    $stderr = StringIO.new
    @ent0 = FelFlame::Entities.new
    @ent1 = FelFlame::Entities.new
    @ent2 = FelFlame::Entities.new
    @cmp0 = @component_manager.new
    @cmp1 = @component_manager.new
    @cmp2 = @component_manager.new
  end

  after :each do
    $stderr = @orig_stderr
    FelFlame::Entities.reverse_each(&:delete)
    @component_manager.reverse_each(&:delete)
  end

  it 'can get a single component' do
    expect { @ent0.component[@component_manager] }.to raise_error(RuntimeError)
    #$stderr.rewind
    #$stderr.string.chomp.should eq("This component belongs to NO entities but you called the method that is intended for components belonging to a single entity.\nYou may have a bug in your logic.")
    @ent0.add @cmp0
    expect(@ent0.component[@component_manager]).to eq(@cmp0)
    expect(@ent0.component[@component_manager]).to eq(@ent0.component(@component_manager))
    @ent0.add @cmp1
    @ent0.component[@component_manager]
    $stderr.rewind
    $stderr.string.chomp.should eq("This entity has MANY of this component but you called the method that is intended for having a single of this component type.\nYou may have a bug in your logic.")
    @ent0.components[@component_manager].reverse_each do |component|
      @ent0.remove component
    end
    expect { @ent0.component[@component_manager] }.to raise_error(RuntimeError)
  end



  it 'responds to array methods' do
    expect(FelFlame::Entities.respond_to?(:[])).to be true
    expect(FelFlame::Entities.respond_to?(:each)).to be true
    expect(FelFlame::Entities.respond_to?(:filter)).to be true
    expect(FelFlame::Entities.respond_to?(:first)).to be true
    expect(FelFlame::Entities.respond_to?(:last)).to be true
    expect(FelFlame::Entities.respond_to?(:somethingwrong)).to be false
  end

  it 'dont respond to missing methods' do
    expect { FelFlame::Entities.somethingwrong }.to raise_error(NoMethodError)
  end


  it 'won\'t add duplicate entities' do
    @ent0.add @cmp0, @cmp0, @cmp1, @cmp1
    expect(@ent0.components[@component_manager].count).to eq(2)
  end

  #it 'has correct ID\'s' do
  #  expect(@ent0.id).to eq(0)
  #  expect(@ent1.id).to eq(1)
  #  expect(@ent2.id).to eq(2)
  #end

  #it 'can be accessed' do
  #  expect(@ent0).to eq(FelFlame::Entities[0])
  #  expect(@ent1).to eq(FelFlame::Entities[1])
  #  expect(@ent2).to eq(FelFlame::Entities[2])
  #end

  it 'can have components attached' do
    @ent0.add @cmp0
    expect(@ent0.components[@component_manager][0]).to eq(@cmp0)

    @ent1.add @cmp1, @cmp2
    expect(@ent1.components[@component_manager].length).to eq(2)
    expect(@ent1.components[@component_manager].include?(@cmp1)).to be true
    expect(@ent1.components[@component_manager].include?(@cmp2)).to be true
  end

  #it 'can get id from to_i' do
  #  expect(@ent0.id).to eq(@ent0.to_i)
  #  expect(@ent1.id).to eq(@ent1.to_i)
  #  expect(@ent2.id).to eq(@ent2.to_i)
  #end

  it 'can have components removed' do
    @ent0.add @cmp0
    expect(@ent0.remove @cmp0).to be true
    expect(@cmp0.entities.empty?).to be true
    expect(@ent0.components[@component_manager].nil?).to be true
    @ent0.add @cmp0
    @cmp0.delete
    expect(@ent0.components[@component_manager].nil?).to be true
  end

  it 'can have many components added then removed' do
    @ent0.add @cmp0, @cmp1, @cmp2
    @ent1.add @cmp0, @cmp1
    @ent2.add @cmp1, @cmp2
    expect(@ent0.components).to eq({@component_manager => [@cmp0,@cmp1,@cmp2]})
    expect(@cmp0.entities).to eq([@ent0,@ent1])
    expect(@cmp1.entities).to eq([@ent0,@ent1,@ent2])
    expect(@cmp2.entities).to eq([@ent0,@ent2])
    @ent1.delete
    expect(@cmp0.entities).to eq([@ent0])
    expect(@cmp1.entities).to eq([@ent0,@ent2])
    expect(@cmp2.entities).to eq([@ent0,@ent2])
    @cmp1.delete
    expect(@ent0.components).to eq({@component_manager => [@cmp0,@cmp2]})
    @component_manager.reverse_each(&:delete)
    expect(@component_manager.length).to eq(0)
    expect(@component_manager.empty?).to be true
    expect(@ent0.components).to eq({})
    expect(@ent2.components).to eq({})
    FelFlame::Entities.reverse_each(&:delete)
    expect(FelFlame::Entities.empty?).to be true
  end
end
