module Admin::Resources::DataTypes::SelectorHelper

  def table_selector_field(attribute, item)
    # item.mapping(attribute)
    value = item.send(attribute)
    select_options = options_for_select(item.class.send(attribute.pluralize), value)
    confirm = Typus::I18n.t("Change %{attribute}?", :attribute => item.class.human_attribute_name(attribute).downcase)
    select_tag attribute, select_options, data: { 
      remote: true, 
      confirm: confirm, 
      url: url_for(controller: "/admin/#{item.class.to_resource}", action: "update_field", id: item.id), 
      method: "POST", 
      type: "JSON", 
      params: "field=#{attribute.gsub(/\?$/, '')}" 
    }
    
  end

  def display_selector(item, attribute)
    item.mapping(attribute)
  end

end
