module Notification
    class Api
        attr_accessor :notification_type

        def initialize(notification_type: ENV['NOTIFICATION_TYPE'])
            self.notification_type = notification_type
        end

        def send_backup_notification(result, date, database, backup_path)
            return if notification_type.nil?
            case notification_type
            when 'slack'
                Slack.new.backup_notification(result, date, database, backup_path)
            when 'webhook'
                Webhook.new.backup_notification(result, date, database, backup_path)
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