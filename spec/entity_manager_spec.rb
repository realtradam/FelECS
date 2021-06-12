require_relative '../felflame.rb'

#class EntitiesTest < Minitest::Test

describe 'Entities' do

  #let :component_manager do
  #  @component_manager ||= FelFlame::Components.new('Test', :param1, param2: 'def')
  #end

  before :all do
    @component_manager ||= FelFlame::Components.new('TestEntity', :param1, param2: 'def')
  end


  before :each do
    @ent0 = FelFlame::Entities.new
    @ent1 = FelFlame::Entities.new
    @ent2 = FelFlame::Entities.new
    @cmp0 = @component_manager.new
    @cmp1 = @component_manager.new
    @cmp2 = @component_manager.new
  end

  after :each do
    FelFlame::Entities.each(&:delete)
    @component_manager.each(&:delete)
  end

  it 'won\'t add duplicate entities' do
    @ent0.add @cmp0, @cmp0, @cmp1, @cmp1
    expect(@ent0.components[@component_manager].count).to eq(2)
  end

  it 'has correct ID\'s' do
    expect(@ent0.id).to eq(0)
    expect(@ent1.id).to eq(1)
    expect(@ent2.id).to eq(2)
  end

  it 'can be accessed' do
    expect(@ent0).to eq(FelFlame::Entities[0])
    expect(@ent1).to eq(FelFlame::Entities[1])
    expect(@ent2).to eq(FelFlame::Entities[2])
  end

  it 'can have components attached' do
    @ent0.add @cmp0
    expect(@ent0.components[@component_manager][0]).to eq(@cmp0.id)

    @ent1.add @cmp1, @cmp2
    expect(@ent1.components[@component_manager].length).to eq(2)
    expect(@ent1.components[@component_manager].include?(@cmp1.id)).to be true
    expect(@ent1.components[@component_manager].include?(@cmp2.id)).to be true
  end

  it 'can have components removed' do
    @ent0.add @cmp0
    expect(@ent0.remove @cmp0).to be true
    expect(@ent0.components[@component_manager].empty?).to be true
  end

  it 'can get id from to_i' do
    expect(@ent0.id).to eq(@ent0.to_i)
    expect(@ent1.id).to eq(@ent1.to_i)
    expect(@ent2.id).to eq(@ent2.to_i)
  end
end
