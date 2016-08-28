module Admin::Resources::DataTypes::PositionHelper

  def table_position_field(attribute, item, connector = " / ")
    locals = { html_position: [], connector: connector, item: item }
    positions = { move_to_top: "Top", move_higher: "Up", move_lower: "Down", move_to_bottom: "Bottom" }
    icons = { move_to_top: "icon-arrow-up", move_higher: "icon-chevron-up", move_lower: "icon-chevron-down", move_to_bottom: "icon-arrow-down" }

    positions.each do |key, value|
      first_item = item.respond_to?(:first?) && ([:move_higher, :move_to_top].include?(key) && item.first?)
      last_item = item.respond_to?(:last?) &&  ([:move_lower, :move_to_bottom].include?(key) && item.last?)

      options = { controller: "/admin/#{item.class.to_resource}", action: "position", id: item.id, go: key }
      unless first_item || last_item
        locals[:html_position] << link_to("<i class=\"#{icons[key]}\"></i>".html_safe, options, { class: "#{Typus::I18n.t(value).downcase} btn btn-small", title: "#{value}" })
      else
        locals[:html_position] << link_to("<i class=\"#{icons[key]}\"></i>".html_safe, options, { class: "#{Typus::I18n.t(value).downcase} btn btn-small hide", title: "#{value}" })
      end

    end

    render "admin/templates/position", locals
  end
  
end
