require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  def test_create_and_find
    i = Item.new
    assert i.save
    assert_equal i, Item.find(i.id)
  end
  
  def test_set_property
    i = Item.create
    assert_equal nil, i.attribute(:name)
    assert_equal nil, Item.find(i.id).attribute(:name)
    
    i.set_attribute(:name, 'hello')
    assert_equal 'hello', i.attribute(:name)

    i.save
    assert_equal 'hello', Item.find(i.id).attribute(:name)
  end
  
end
