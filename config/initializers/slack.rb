require Rails.root.join('app', 'services', 'slack_notifier')

SlackNotifier.slack_webhook_url = Rails.configuration.x.slack_webhook_url
