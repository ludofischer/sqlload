require 'test/unit'
require 'sqlloader'

class DataSetTest < Test::Unit::TestCase

  def setup
    @data_directory = 'samples/SQL/test'
    @dataset = DataSet.new(@data_directory, user_config = {})
  end
  
  def test_configuration
    assert @dataset.directory == @data_directory
    assert !@dataset.config.empty?
    assert !@dataset.ups.empty?
    assert @dataset.downs.empty?
  end

  def test_reset
    assert_raise ArgumentError do 
      @dataset.reset
    end
  end    

  def test_load
    @dataset.load
  end
end
