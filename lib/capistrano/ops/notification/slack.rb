module Notification
    class Slack
        require 'uri'
        require 'net/http'
        require 'net/https'
        def initialize
            @slack_secret = ENV['SLACK_SECRET']
            @slack_channel = ENV['SLACK_CHANNEL']
            @slack_base_url ='https://slack.com/api/'
        end

        def notify(message)
            return if @slack_secret.nil? || @slack_channel.nil?
            uri = URI.parse("#{@slack_base_url}chat.postMessage")
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            request = Net::HTTP::Post.new(uri.request_uri, initHeader = {'Content-Type' =>'application/json', 'Authorization' => 'Bearer ' + @slack_secret})
            request.body = {
                channel: @slack_channel,
                text: message
            }.to_json
            response = http.request(request)
            puts response.body
        end

        def backup_notification(result, date, database, backup_path)
            return if @slack_secret.nil? || @slack_channel.nil?
            uri = URI.parse("#{@slack_base_url}chat.postMessage")
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            request = Net::HTTP::Post.new(uri.request_uri, initHeader = {'Content-Type' =>'application/json', 'Authorization' => 'Bearer ' + @slack_secret})
            message_one = "Backup of #{database} successfully finished at #{Time.now}"
            message_two = "Backup path:\`#{backup_path}/#{database}_#{date}.dump\`"
            data = {
                channel: @slack_channel,
                blocks: [
                    {
                        type: 'header',
                        text: {
                            type: 'plain_text',
                            text: ENV['DEFAULT_URL'] || "#{database} Backup",
                            emoji: true
                        }
                    },
                    {
                        type: 'section',
                        text: {
                            type: 'mrkdwn',
                            text: result ? "#{message_one}\n#{message_two}" : "Backup of #{database} failed at #{Time.now}"
                        }
                    }
                ]
            }
            request.body = data.to_json
            begin
             response = JSON.parse(http.request(request).body)
             if response['ok'] == false
                raise Notification::Error, response['error']
             end
             response
            rescue => e
                puts "Slack error: \n\t#{e.message}"
            end
        end
    end
end
