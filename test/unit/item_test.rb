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
  
  def test_full_text_search
    i1 = Item.create(:identifier => '1', :name => 'hello')
    i2 = Item.create(:identifier => '2', :name => 'world')
    assert_equal 1, Item.search("world").size
    assert_equal [i2], Item.search("world").to_a
    assert_equal [i1, i2], Item.search("hello OR world").to_a
  end
  
  def test_checkin_versioning
    i = Item.create(:identifier => 'kim',:name => 'hello')
    i.checkin
    i.checkout
    i.update_attributes(:name => 'world')
    i.checkin
    
    assert_equal 3, i.versions.size
  end
  
  def test_restore_version
    i = Item.create(:identifier => 'kim',:name => 'hello')
    i.checkin
    i.checkout
    i.update_attributes(:name => 'world')
    i.checkin
    
    i.restore(i.versions[1])
    assert_equal 'hello', i.name
    assert_equal 'hello', Item.find('kim').name

    assert_equal 3, i.versions.size
  end
  
end
