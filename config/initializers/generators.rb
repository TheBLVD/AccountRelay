# Always set primary_key as uuid and not incrememental id
Rails.application.config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
end
