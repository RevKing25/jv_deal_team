class PropertyImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url(*args)
    "/images/default_property_image.jpg"
  end

  process :quality => 100
  process :resize_to_fit => [800, 800]
  process :apply_sharpen # Use custom method

  version :thumb do
    process :quality => 100
    process :resize_to_fit => [200, 200]
    process :apply_sharpen
  end

  version :medium do
    process :quality => 100
    process :resize_to_fit => [400, 400]
    process :apply_sharpen
  end

  def extension_allowlist
    %w(jpg jpeg gif png)
  end

  def quality(percentage)
    manipulate! do |img|
      img.quality(percentage.to_s)
      img = yield(img) if block_given?
      img
    end
  end

  # Define custom sharpening method
  def apply_sharpen
    manipulate! do |img|
      img.sharpen("0x0.8") # Uses MiniMagick's sharpen method
      img
    end
  end
end