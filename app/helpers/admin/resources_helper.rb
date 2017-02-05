module Admin::ResourcesHelper

  def admin_search(resource = @resource, params = self.params)
    if (typus_search = resource.typus_defaults_for(:search)) && typus_search.any?

      hidden_filters = params.to_h.dup

      rejections = %w(id controller action locale utf8  order_by search page subdomain)
      hidden_filters.delete_if { |k, _| rejections.include?(k.to_s) }

      render "helpers/admin/#{resource.to_resource}/search", hidden_filters: hidden_filters
    end
  rescue ActionView::MissingTemplate
    render 'helpers/admin/resources/search', hidden_filters: hidden_filters
  end

  def build_sidebar
    app_name = @resource.typus_application
    resources = admin_user.application(app_name).map(&:constantize).delete_if { |k| k.typus_options_for(:hide_from_sidebar) }

    if resources.any?
      render 'helpers/admin/resources/sidebar', resources: resources
    else
      render 'admin/dashboard/sidebar'
    end
  end

end