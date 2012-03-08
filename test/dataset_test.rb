require 'test/unit'
require 'lib/dataset'

class DataSetTest < Test::Unit::TestCase

  def test
    directory = 'SQL/test'
    dataset = DataSet.new(directory, user_config = {})
    
    assert !dataset.config.empty?

    assert !dataset.ups.empty?
    assert dataset.downs.empty?
  
    assert_raise ArgumentError do 
      dataset.reset
    end
    
    assert dataset.directory == directory
    dataset.load
  end
end
