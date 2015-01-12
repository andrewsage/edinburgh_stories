CarrierWave.configure do |config|
  if Rails.env.test?
    config.enable_processing = false    
  else
    config.storage    = :fog
    config.fog_public = true

    config.fog_credentials = {
      :provider           => 'AWS',

      :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],
      :region                 => 'eu-west-1',
    }
    config.fog_directory = ENV['S3_BUCKET_NAME']

    # To let CarrierWave work on heroku
    config.cache_dir = "#{Rails.root}/public/uploads"
  end
end

