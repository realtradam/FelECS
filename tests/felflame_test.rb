require 'minitest/autorun'
require_relative '_test_helper.rb'

require_relative '../felflame.rb'

describe 'Entities' do
  before do
  end

  it 'FelFlame aliased to FF' do
    _(FF).must_equal FelFlame
  end

  it 'Entities aliased to Ent' do
    _(FF::Ent).must_equal FelFlame::Entities
  end

  it 'Components aliased to Cmp' do
    _(FF::Cmp).must_equal FelFlame::Components
  end

  it 'Systems aliased to Sys' do
    _(FF::Sys).must_equal FelFlame::Systems
  end

  it 'Scenes aliased to Scn' do
    _(FF::Scn).must_equal FelFlame::Scene
  end

  it 'Stage aliased to Stg' do
    _(FF::Stg).must_equal FelFlame::Stage
  end
end
