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
    # 
    # def test_set_property
    #   i = Item.create
    #   assert_equal nil, i.attribute(:name)
    #   assert_equal nil, Item.find(i.identifier).attribute(:name)
    #   
    #   i.set_attribute(:name, 'hello')
    #   assert_equal 'hello', i.attribute(:name)
    # 
    #   i.save
    #   assert_equal 'hello', Item.find(i.id).attribute(:name)
    # end
    # 
    # def test_update_attribute
    #   i = Item.create(:name)
    # end
  
end
