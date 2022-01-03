# frozen_string_literal: true

require_relative '../lib/felflame'

describe 'Components' do
  # let :component_manager do
  #  @component_manager ||= FelFlame::Components.new('TestComponents', :param1, param2: 'def')
  # end

  before :all do
    @component_manager ||= FelFlame::Components.new('TestComponents', :param1, param2: 'def')
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

  it 'can get a single entity' do
    @cmp0.entity
    $stderr.rewind
    $stderr.string.chomp.should eq("This component belongs to NO entities but you called the method that is intended for components belonging to a single entity.\nYou may have a bug in your logic.")
    @ent0.add @cmp0
    expect(@cmp0.entity).to eq(@ent0)
    @ent1.add @cmp0
    @cmp0.entity
    $stderr.rewind
    $stderr.string.chomp.should eq("This component belongs to MANY entities but you called the method that is intended for components belonging to a single entity.\nYou may have a bug in your logic.")
  end

  it 'responds to array methods' do
    expect(@component_manager.respond_to?(:[])).to be true
    expect(@component_manager.respond_to?(:each)).to be true
    @component_manager.each do |component|
      expect(component.respond_to?(:param1)).to be true
    end
    expect(@component_manager.respond_to?(:filter)).to be true
    expect(@component_manager.respond_to?(:first)).to be true
    expect(@component_manager.respond_to?(:last)).to be true
    expect(@component_manager.respond_to?(:somethingwrong)).to be false
  end

  it 'dont respond to missing methods' do
    expect { @component_manager.somethingwrong }.to raise_error(NoMethodError)
  end

  it 'Component module responds to array methods' do
    expect(FelFlame::Components.respond_to?(:[])).to be true
    expect(FelFlame::Components.respond_to?(:each)).to be true
    FelFlame::Components.each do |component_manager|
      expect(component_manager.respond_to?(:addition_triggers)).to be true
    end
    expect(FelFlame::Components.respond_to?(:filter)).to be true
    expect(FelFlame::Components.respond_to?(:first)).to be true
    expect(FelFlame::Components.respond_to?(:last)).to be true
    expect(FelFlame::Components.respond_to?(:somethingwrong)).to be false
  end

  it 'Component module doesnt respond to missing methods' do
    expect { FelFlame::Components.somethingwrong }.to raise_error(NoMethodError)
  end

  it 'can delete a component' do
    # component_id = @cmp1.id
    @ent0.add @cmp1
    length = @component_manager.length
    expect(@cmp1.delete).to be true
    expect(@component_manager.length).to eq(length - 1)
    # expect(@cmp1.id).to be_nil
    # expect(@component_manager[component_id]).to be_nil
    expect(@cmp1.entities).to eq([])
  end

  it 'can iterate component managers' do
    all_components_symbols = FelFlame::Components.constants
    all_components = all_components_symbols.map do |symbol|
      FelFlame::Components.const_get symbol
    end
    expect(all_components).to eq(FF::Components.each.to_a)
    expect(all_components.length).to be > 0
    expect(FelFlame::Components.each).to be_an Enumerator
  end

  it 'can change params on initialization' do
    @cmp3 = @component_manager.new(param1: 'ok', param2: 10)
    expect(@cmp3.to_h).to eq(param1: 'ok', param2: 10)
  end

  it 'sets default params correctly' do
    expect(@cmp0.param1).to be_nil
    expect(@cmp0.param2).to eq('def')
    expect(@cmp1.param1).to be_nil
    expect(@cmp1.param2).to eq('def')
    expect(@cmp2.param1).to be_nil
    expect(@cmp2.param2).to eq('def')
  end

  it 'can read attributes' do
    expect(@cmp0.to_h).to eq(param2: 'def')
    expect(@cmp1.to_h).to eq(param2: 'def')
    expect(@cmp2.to_h).to eq(param2: 'def')
  end

  it 'can set attrs' do
    expect(@cmp0.param1 = 4).to eq(4)
    expect(@cmp1.update_attrs(param1: 3, param2: 'new')).to eq(param1: 3, param2: 'new')
    expect(@cmp1.to_h).to eq(param1: 3, param2: 'new')
  end

  it 'can be used as a singleton' do
    expect(@component_manager.first).to eq(@cmp0)
  end

  it 'can be accessed' do
    expect(@component_manager[0].respond_to?(:param1)).to eq(true)
    expect(@component_manager[1].respond_to?(:param1)).to eq(true)
    expect(@component_manager[2].respond_to?(:param1)).to eq(true)
  end

  it 'cant overwrite exiting component managers' do
    FelFlame::Components.new('TestComponent1')
    expect { FelFlame::Components.new('TestComponent1') }.to raise_error(NameError)
  end

  it 'can\'t create an attribute when its name is an existing method' do
    # expect { FelFlame::Components.new('TestComponent2', :id) }.to raise_error(NameError)
    expect { FelFlame::Components.new('TestComponent2', :addition_triggers) }.to raise_error(NameError)
    expect { FelFlame::Components.new('TestComponent2', :removal_triggers) }.to raise_error(NameError)
    expect { FelFlame::Components.new('TestComponent2', :attr_triggers) }.to raise_error(NameError)
    expect { FelFlame::Components.new('TestComponent3', :same, :same) }.to raise_error(NameError)
  end
end
