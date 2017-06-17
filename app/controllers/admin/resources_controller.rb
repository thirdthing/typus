class Admin::ResourcesController < Admin::BaseController

  include Admin::Navigation
  include Admin::Actions
  include Admin::Filters
  include Admin::Format
  include Admin::Headless

  Whitelist = [:edit, :update, :destroy, :toggle]

  before_action :get_model
  before_action :set_context
  before_action :get_object, :only => Whitelist + [:show]
  before_action :check_resource_ownership, :only => Whitelist
  before_action :check_if_user_can_perform_action_on_resources

  def index
    get_objects

    custom_actions_for(:index).each do |action|
      prepend_resources_action(action.titleize, {:action => action, :id => nil})
    end

    respond_to do |format|
      format.html do
        set_default_action
        add_resource_action("Destroy", {:action => "destroy"}, { :data => { :confirm => "#{Typus::I18n.t("Trash")}?" }, :method => 'delete'})
        get_paginated_data
      end

      format.csv { generate_csv }
      format.json { export(:json) }
      format.xml { export(:xml) }
    end
  end

  def new
    @item = @resource.new(item_params_for_new)

    if params[:_from_parent]
      @from_parent = params[:_from_parent]
    end

    respond_to do |format|
      format.html { render :new }
      format.json { render :json => @item }
    end
  end

  def create
    @item = @resource.new
    @item.assign_attributes(item_params_for_create)

    set_attributes_on_create

    respond_to do |format|
      if @item.save
        format.html { redirect_on_success }
        format.json { render :json => @item, :status => :created, :location => @item }
      else
        format.html { render :action => "new", :status => :unprocessable_entity }
        format.json { render :json => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    if params[:_from_parent]
      @from_parent = params[:_from_parent]
    end
    custom_actions_for(:edit).each do |action|
      prepend_resources_action(action.titleize, {:action => action, :id => @item})
    end
  end

  def show
    check_resource_ownership if @resource.typus_options_for(:only_user_items)

    if admin_user.can?('edit', @resource)
      prepend_resources_action("Edit", {:action => 'edit', :id => @item})
    end

    custom_actions_for(:show).each do |action|
      prepend_resources_action(action.titleize, {:action => action, :id => @item})
    end

    respond_to do |format|
      format.html
      format.xml { render :xml => @item }
      format.json { render :json => @item }
    end
  end

  def update
    cleanup_attributes_before_update

    respond_to do |format|
      if @item.update_attributes(item_params_for_update)
        set_attributes_on_update
        format.html { redirect_on_success }
        format.json { render :json => @item }
      else
        format.html { render :edit, :status => :unprocessable_entity }
        format.json { render :json => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    if @item.destroy
      notice = Typus::I18n.t("%{model} successfully removed.", :model => @resource.model_name.human)
    else
      alert = @item.errors.full_messages
    end
    redirect_to :back, :notice => notice, :alert => alert
  end

  def toggle
    @item.toggle(params[:field])

    respond_to do |format|
      if @item.save
        format.html do
          notice = Typus::I18n.t("%{model} successfully updated.", :model => @resource.model_name.human)
          redirect_to :back, :notice => notice
        end
        format.json { render :json => @item }
      else
        format.html { render :edit }
        format.json { render :json => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update_field
    respond_to do |format|
      if @item.update_attribute(params[:field], params[params[:field].to_sym])
        format.html do
          notice = Typus::I18n.t("%{model} successfully updated.", :model => @resource.model_name.human)
          redirect_to :back, :notice => notice
        end
        format.json { render :json => @item }
      else
        format.html { render :edit }
        format.json { render :json => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

  def get_model
    @resource = resource
    @object_name = ActiveModel::Naming.singular(@resource)
  end

  def resource
    params[:controller].extract_class
  rescue
    params[:controller].extract_singular_class
  end
  helper_method :resource

  def set_context
    @resource
  end
  helper_method :set_context

  def get_object
    @item = @resource.find(params[:id])
  end

  def get_objects
    cleanup_params
    set_scope
    set_wheres
    set_joins
    check_resources_ownership if @resource.typus_options_for(:only_user_items)
    set_order if @resource.respond_to?(:order)
    set_eager_loading
  end

  def fields
    @resource.typus_fields_for(action_name)
  end
  helper_method :fields

  def set_scope
    return unless params[:scope]

    if @resource.typus_scopes.include?(params[:scope])
      @resource = @resource.send(params[:scope])
    else
      not_allowed("Not allowed! Requested scope not defined on your whitelist.")
    end
  end

  def set_wheres
    @resource.build_conditions(params).each do |condition|
      @resource = @resource.where(condition)
    end
  end

  def set_joins
    @resource.build_my_joins(params).each do |join|
      @resource = @resource.joins(join)
    end
  end

  def set_order
    params[:sort_order] ||= "desc"

    if (order = params[:order_by] ? "#{params[:order_by]} #{params[:sort_order]}" : @resource.typus_order_by).present?
      @resource = @resource.reorder(order)
    end
  end

  def set_eager_loading
    if (eager_loading = @resource.reflect_on_all_associations(:belongs_to).reject { |i| i.options[:polymorphic] }.map(&:name)).any?
      @resource = @resource.includes(eager_loading)
    end
  end

  def redirect_on_success
    path = params.dup.cleanup

    options = if params[:_addanother]
      { :action => 'new', :id => nil }
    elsif params[:_continue]
      { :action => 'edit', :id => @item.id }
    else
      if params[:_from_parent]
        path = params[:_from_parent]
      end
      { :action => nil, :id => nil }
    end

    message = action_name.eql?('create') ? "%{model} successfully created." : "%{model} successfully updated."
    notice = Typus::I18n.t(message, :model => @resource.model_name.human)

    if path.is_a?(Hash)
      redirect_to path.merge!(options.merge(:_from_parent => params[:_from_parent])).compact.to_hash, :notice => notice
    else
      redirect_to path, :notice => notice
    end

  end

  def set_default_action
    default_action = @resource.typus_options_for(:default_action_on_item)
    action = admin_user.can?('edit', @resource.model_name.to_s) ? default_action : "show"
    prepend_resource_action(action.titleize, {:action => action})
  end

  def custom_actions_for(action)
    return [] if headless_mode?
    @resource.typus_actions_on(action).reject { |a| admin_user.cannot?(a, @resource.model_name) }
  end

  def item_params_for_new
    if params[:resource]
      params[@object_name] = params.delete(:resource)
      permit_params!
    end
  end

  def item_params_for_create
    permit_params!
  end

  def item_params_for_update
    if (attr = params[:_nullify])
      params[@object_name] = { attr => nil }
    end

    permit_params!
  end

  def permit_params!
    params[@object_name].permit!
  end

  def cleanup_params
    params.delete_if { |_, v| v.empty? }
  end

  def cleanup_attributes_before_update
    if Typus.user_class && @item.is_a?(Typus.user_class) && admin_user.is_not_root?
      params[Typus.user_class_as_symbol].delete(:role)
    end
  end

end
