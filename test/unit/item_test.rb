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
  
  def test_attribute_methods
    i = Item.new(:identifier => '1')
    assert_equal nil, i.name
    i.name = "hello"
    i.save
    assert_equal 'hello', Item.find('1').name
  end
  
  def test_update_attributes
    i = Item.create(:identifier => '1')
    i.update_attributes(:name => 'hello world')
    assert_equal 'hello world', i.name
    assert_equal 'hello world', Item.find('1').name
  end
  
  
  def test_boolean_attribute
    i = Item.new(:identifier => '1')
    i.attr_bool = true
    i.save
    assert_equal true, Item.find('1').attr_bool
    assert_equal true, Item.find('1').attr_bool?
  end
  
  def test_long_attribute
    i = Item.new(:identifier => '1')
    i.attr_long = 11333
    i.save
    assert_equal 11333, Item.find('1').attr_long
  end
end
