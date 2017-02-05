module Admin::Resources::DataTypes::PaperclipHelper

  def display_paperclip(item, attribute)
    # options = { :width => 25 }
    options = {} # Don't add a width
    typus_paperclip_preview(item, attribute, options)
  end

  def table_paperclip_field(attribute, item)
    # options = { :width => 25 }
    options = {} # Don't add a width
    typus_paperclip_preview(item, attribute, options)
  end

  def link_to_detach_attribute_for_paperclip(attribute)
    validators = @item.class.validators.delete_if { |i| i.class != Paperclip::Validators::AttachmentPresenceValidator }.map(&:attributes).flatten.map(&:to_s)
    attachment = @item.send(attribute)

    if attachment.present? && !validators.include?(attribute) && attachment
      attribute_i18n = @item.class.human_attribute_name(attribute)
      link = link_to(
        t('typus.buttons.remove'),
        { action: 'update', id: @item.id, _nullify: attribute, _continue: true },
        { data: { confirm: t('typus.shared.confirm_question') } }
      )

      label_text = <<-HTML
#{attribute_i18n}
<small>#{link}</small>
      HTML
      label_text.html_safe
    end
  end

  def typus_paperclip_preview(item, attachment, options = {})
    if (data = item.send(attachment)).exists?
      styles = data.styles.keys
      if (data.content_type =~ /^image\/.+/ || data.content_type =~ /^application\/pdf/) && styles.include?(Typus.file_preview) && styles.include?(Typus.file_thumbnail)
        render "admin/templates/paperclip_preview",
               :preview => data.url(Typus.file_preview, false),
               :thumb => data.url(Typus.file_thumbnail, false),
               :options => options
      else
        link_to data.original_filename, data.url(:original, false)
      end
    end
  end

end
