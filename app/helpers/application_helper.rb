module ApplicationHelper
  def can_view_full_property_details?(property)
    return false unless user_signed_in?
    property.user == current_user || current_user.interested_properties.include?(property)
  end

  def can_view_full_profile?(user)
    user_signed_in? && (current_user == user || current_user.connected_with?(user))
  end


  def render_property_preview(property)
    content_tag(:div, class: "property-preview") do
      if property.images.any?
        concat(image_tag(property.images.first.medium.url || "/images/default_property_image.jpg", class: "card-img-top", alt: "Property image", loading: 'lazy'))
      else
        concat(image_tag("/images/default_property_image.jpg", class: "card-img-top", alt: "Property image", loading: 'lazy'))
      end
      concat(content_tag(:p, "#{property.city}, #{full_state_name(property.state)}", class: "text-muted mt-2"))
    end
  end

  def full_state_name(abbreviation)
    return unless abbreviation.present?
    state_pair = Property::US_STATES.find { |name, abbr| abbr == abbreviation }
    state_pair ? state_pair[0] : abbreviation
  end
end