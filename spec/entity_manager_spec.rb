# frozen_string_literal: true

require_relative '../lib/felecs'

# class EntitiesTest < Minitest::Test

describe 'Entities' do
  before :all do
    $VERBOSE = nil
    @component_manager ||= FelECS::Components.new('TestEntity', :param1, param2: 'def')
  end

  before :each do
    @orig_stderr = $stderr
    $stderr = StringIO.new
    @ent0 = FelECS::Entities.new
    @ent1 = FelECS::Entities.new
    @ent2 = FelECS::Entities.new
    @cmp0 = @component_manager.new
    @cmp1 = @component_manager.new
    @cmp2 = @component_manager.new
  end

  after :each do
    $stderr = @orig_stderr
    FelECS::Entities.reverse_each(&:delete)
    @component_manager.reverse_each(&:delete)
  end

  it 'can get a single component' do
    expect { @ent0.component[@component_manager] }.to raise_error(RuntimeError)
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
    expect(FelECS::Entities.respond_to?(:[])).to be true
    expect(FelECS::Entities.respond_to?(:each)).to be true
    FelECS::Entities.each do |entity|
      expect(entity.respond_to?(:components)).to be true
    end
    expect(FelECS::Entities.respond_to?(:filter)).to be true
    expect(FelECS::Entities.respond_to?(:first)).to be true
    expect(FelECS::Entities.respond_to?(:last)).to be true
    expect(FelECS::Entities.respond_to?(:somethingwrong)).to be false
  end

  it 'dont respond to missing methods' do
    expect { FelECS::Entities.somethingwrong }.to raise_error(NoMethodError)
  end

  it 'won\'t add duplicate entities' do
    @ent0.add @cmp0, @cmp0, @cmp1, @cmp1
    expect(@ent0.components[@component_manager].count).to eq(2)
  end

  it 'can be accessed' do
    expect(FelECS::Entities[0].respond_to?(:components)).to eq(true)
    expect(FelECS::Entities[1].respond_to?(:components)).to eq(true)
    expect(FelECS::Entities[2].respond_to?(:components)).to eq(true)
  end

  it 'can have components attached' do
    @ent0.add @cmp0
    expect(@ent0.component[@component_manager]).to eq(@cmp0)

    @ent1.add @cmp1, @cmp2
    expect(@ent1.components[@component_manager].length).to eq(2)
    expect(@ent1.components[@component_manager].include?(@cmp1)).to be true
    expect(@ent1.components[@component_manager].include?(@cmp2)).to be true
  end

  it 'can have components removed' do
    @ent0.add @cmp0
    expect(@ent0.remove(@cmp0)).to be true
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
    expect(@ent0.components).to eq({ @component_manager => [@cmp0, @cmp1, @cmp2] })
    expect(@cmp0.entities).to eq([@ent0, @ent1])
    expect(@cmp1.entities).to eq([@ent0, @ent1, @ent2])
    expect(@cmp2.entities).to eq([@ent0, @ent2])
    @ent1.delete
    expect(@cmp0.entities).to eq([@ent0])
    expect(@cmp1.entities).to eq([@ent0, @ent2])
    expect(@cmp2.entities).to eq([@ent0, @ent2])
    @cmp1.delete
    expect(@ent0.components).to eq({ @component_manager => [@cmp0, @cmp2] })
    @component_manager.reverse_each(&:delete)
    expect(@component_manager.length).to eq(0)
    expect(@component_manager.empty?).to be true
    expect(@ent0.components).to eq({})
    expect(@ent2.components).to eq({})
    FelECS::Entities.reverse_each(&:delete)
    expect(FelECS::Entities.empty?).to be true
  end
end
