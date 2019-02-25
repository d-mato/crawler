Sidekiq.configure_server do |config|
  config.redis = { namespace: 'crawler' }
end

Sidekiq.configure_client do |config|
  config.redis = { namespace: 'crawler' }
end
