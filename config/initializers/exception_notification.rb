if Rails.env.production?
  Rails.application.config.middleware.use ExceptionNotification::Rack,
    slack: {
      webhook_url: Rails.application.credentials.dig(:slack, :webhook_url),
      username: 'crawler',
      additional_parameters: {
        mrkdwn: true
      },
      additional_fields: [
        { title: 'Mention', value: '<!channel>' }
      ]
    }
end
