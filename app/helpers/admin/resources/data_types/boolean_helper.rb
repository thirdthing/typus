module Admin::Resources::DataTypes::BooleanHelper

  def display_boolean(item, attribute)
    data = item.send(attribute)
    boolean_assoc = item.class.typus_boolean(attribute)
    (data ? boolean_assoc.rassoc("true") : boolean_assoc.rassoc("false")).first
  end

  def table_boolean_field(attribute, item)
    status = item.send(attribute)
    boolean_assoc = item.class.typus_boolean(attribute)
    human_boolean = (status ? boolean_assoc.rassoc("true") : boolean_assoc.rassoc("false")).first

    confirm = Typus::I18n.t("Change %{attribute}?", :attribute => item.class.human_attribute_name(attribute).downcase)
    # link_to Typus::I18n.t(human_boolean), options, :data => { :confirm => confirm }
    check_box_tag attribute, item.id, status, data: { 
      remote: true, 
      confirm: confirm, 
      url: url_for(controller: "/admin/#{item.class.to_resource}", action: "toggle", id: item.id), 
      method: "POST", 
      type: "JSON", 
      params: "field=#{attribute.gsub(/\?$/, '')}" 
    }
  end

  def boolean_filter(filter)
    values  = @resource.typus_boolean(filter)
    items = [[Typus::I18n.t("Show by %{attribute}", :attribute => @resource.human_attribute_name(filter).downcase), ""]]
    items += values.map { |k, v| [Typus::I18n.t(k.humanize), v] }
  end

end
