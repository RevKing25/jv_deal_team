class ProfilePhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url(*args)
    "/images/default_profile_photo.jpg"
  end

  process :quality => 100
  process :resize_to_fill => [150, 150]

  version :thumb do
    process :quality => 100
    process :resize_to_fill => [40, 40]
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
end
