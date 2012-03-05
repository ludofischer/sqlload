require 'test/unit'
require 'lib/dataset'

class DataSetTest < Test::Unit::TestCase

  def test
    directory = 'SQL'
    dataset = DataSet.new(directory, user_config = {})
    
    assert !dataset.config.empty?

    assert !dataset.ups.empty?
    assert dataset.downs.empty?
  
    assert_raise ArgumentError do 
      dataset.reset
    end

    dataset.load
  end
end
