module Admin::Resources::SidebarHelper

  def build_sidebar
    locals = { :sidebar_title => Typus::I18n.t("Dashboard"), :actions => [], :custom_actions => []}

    if @resource
      locals[:actions] = [sidebar_list(@resource.name), sidebar_add_new(@resource.name)].compact
      if @resources_actions
        @resources_actions.each do |ca|
          locals[:custom_actions].push(sidebar_custom_actions(ca))
        end
      end
      locals[:sidebar_title] = @resource.model_name.human.pluralize
    end

    render "helpers/admin/resources/sidebar", locals
  end

  def sidebar_add_new(klass)
    if admin_user.can?("create", klass)
      { :message => Typus::I18n.t("Add"),
        :url => { :controller => "/admin/#{klass.to_resource}", :action => "new" },
        :icon => "plus" }
    end
  end

  def sidebar_list(klass)
    if admin_user.can?("read", klass)
      { :message => Typus::I18n.t("List"),
        :url => { :controller => "/admin/#{klass.to_resource}", :action => "index" },
        :icon => "list" }
    end
  end
  
  def sidebar_custom_actions(custom_action)
    klass = @resource.name
    params[:action] = custom_action[1][:action]
    if admin_user.can?(params[:action], klass)
      { :message => custom_action[0],
        :url => { :controller => "/admin/#{klass.to_resource}", :action => params[:action] },
        :icon => "asterisk" }
    end
  end

  # TODO: Move it to the header.
  def sidebar_view_site
    if Typus.link_to_view_site
      { :message => Typus::I18n.t("View Site"),
        :url => Typus.admin_title_link,
        :link_to_options => { :target => '_blank' },
        :icon => "share" }
    end
  end

end
