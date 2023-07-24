module Notification
    class Api
        attr_accessor :notification_type, :notification_level

        def initialize(notification_type: ENV['NOTIFICATION_TYPE'], notification_level: ENV['NOTIFICATION_LEVEL'])
            self.notification_type = notification_type
            self.notification_level = notification_level || 'error'
        end

        def send_backup_notification(result, title, content)
            return if notification_type.nil?
            case notification_type
            when 'slack'
                Slack.new.backup_notification(result, title, content, notification_level)
            when 'webhook'
                Webhook.new.backup_notification(result, title, content, notification_level)
            end
        end

        def send_notification(message)
            return if notification_type.nil?
            case notification_type
            when 'slack'
                Slack.new.notify(message)
            when 'webhook'
                p 'webhook'
            end
        end
    end
end