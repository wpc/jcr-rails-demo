class ItemTypesController < ApplicationController
  def index
    @types = JCR::Repository.node_types
  end
  
  def new
    @type = TypeTemplate.new
  end
  
  def create
    type = TypeTemplate.new(params[:type_template])
    
  end
end
