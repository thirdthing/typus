module Admin::Resources::DataTypes::AssociationsHelper
  
  def get_template_for(resource, association, type, partial=true)
    prefix = "admin/#{resource.table_name}/templates"
    deep_prefix = "#{prefix}/#{association}"
    if lookup_context.template_exists?(type, deep_prefix, partial)
      template = "#{deep_prefix}/#{type}"
    elsif lookup_context.template_exists?(type, prefix, partial)
      template = "#{prefix}/#{type}"
    else
      template = "admin/templates/#{type}"
    end
    
    template
  end
  
end