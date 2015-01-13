# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::MimeTypes

  WHITE_LIST = %w(JPG JPEG GIF PNG jpg jpeg gif png)

  def store_dir
    "uploads/memory/#{mounted_as}/#{model.id}"
  end

  ## PROCESSING
  def set_exif_location
    imgfile = EXIFR::JPEG.new(current_path)
    return unless imgfile

    @latitude = imgfile.gps.latitude
    @longitude = imgfile.gps.longitude
  end



  def fix_exif_rotation
    manipulate! do |img|
      img.tap(&:auto_orient)
    end
  end

  def manual_rotation
    manipulate! do |img|
      img.rotate(model.rotation)
      img = yield(img) if block_given?
      img
    end
  end

  def is_rotated?(file)
    model.rotated?
  end

  process :set_exif_location
  process :fix_exif_rotation
  process :set_content_type
  process :manual_rotation, if: :is_rotated?
  version :thumb do
    process :resize_to_fit => [300, nil]
  end

  def filename
    "#{secure_token}.#{ext}" if original_filename.present?
  end

  def extension_white_list
    if !WHITE_LIST.include?(file.extension) && WHITE_LIST.include?(filetype)
      [file.extension]
    else
      %w(JPG JPEG GIF PNG jpg jpeg gif png)
    end
  end

  protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end

  def filetype
    @filetype ||= FastImage.type(current_path).to_s
  end

  def ext
    @ext ||= WHITE_LIST.include?(file.extension) ? file.extension : filetype
  end
end

