require 'test/unit'
require 'sqlload'

class DataSetTest < Test::Unit::TestCase

  def setup
    @data_directory = 'samples/SQL/test'
    @dataset = DataSet.new(@data_directory, user_config = {})
  end
  
  def test_directory
    assert @dataset.directory == @data_directory, 'The configuration directory is picked up correctly'
  end
  
  def test_configuration
    assert !@dataset.config.empty?, 'The connection configuration is picked up correctly'
  end

  def test_load_scripts
    assert @dataset.ups.size == 1, 'Load scripts are recognized'
  end
  
  def test_reset_script
    assert @dataset.downs.empty?, 'There are no reset scripts'
  end

  def test_psql_scripts
    assert @dataset.raws.length == 1, 'psql scripts are recognized'
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
