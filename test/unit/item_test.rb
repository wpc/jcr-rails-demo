require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  def setup
    JCR::Repository.reset
  end
  
  def test_save_and_find
    item = Item.new(:identifier => 'hello')
    assert item.save
    assert_equal 'hello', item.identifier
    assert_equal item, Item.find('hello')
  end

  def test_read_write_attribute
    i = Item.create(:identifier => '1')
    assert_equal nil, i.read_attribute(:name)
    assert_equal nil, Item.find('1').read_attribute(:name)
    
    i.write_attribute(:name, 'hello')
    assert_equal 'hello', i.read_attribute(:name)
    
    assert_equal nil, Item.find('1').read_attribute(:name)
    i.save
    assert_equal 'hello', Item.find('1').read_attribute(:name)
  end

  
end
