require 'minitest/autorun'
require_relative '_test_helper.rb'

require_relative '../component_manager.rb'

describe 'Sample' do
  before do
    #setup vars here
  end

  it 'does something' do
    _(4).must_equal 4
    #_(@thing).mustequal 'something
  end
end
