# Module designed to work with `acts_as_list`.

require 'active_support/concern'

module Admin
  module ActsAsList

    extend ActiveSupport::Concern

    included do
      before_filter :get_object, :except => [:index, :new, :create]
      before_filter :check_resource_ownership, :except => [:index, :new, :create, :show]
    end

    def position
      if %w(move_to_top move_higher move_lower move_to_bottom insert_at).include?(params[:go])
        if params[:go] == 'insert_at'
          @item.send(params[:go], params[:index].to_i)
        else
          @item.send(params[:go])
        end
        notice = Typus::I18n.t("%{model} successfully updated.", :model => @resource.model_name.human)
        respond_to do |format|
          format.html { redirect_to :back, :notice => notice }
          format.json { render :json => @item }
        end
      else
        not_allowed
      end
    end

  end
end
