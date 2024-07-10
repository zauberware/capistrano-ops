# frozen_string_literal: true

require 'faraday'
require 'json'

module Notification
  class Slack
    def initialize
      @slack_secret = ENV['SLACK_SECRET']
      @slack_channel = ENV['SLACK_CHANNEL']
      @conn = Faraday.new(url: 'https://slack.com/api/') do |faraday|
        faraday.headers['Content-Type'] = 'application/json'
        faraday.headers['Authorization'] = "Bearer #{@slack_secret}"
      end
    end

    def notify(message)
      return if @slack_secret.nil? || @slack_channel.nil?

      begin
        res = @conn.post('chat.postMessage') do |req|
          req.body = {
            "channel": @slack_channel,
            "text": message
          }.to_json
        end
        response = JSON.parse(res.body)
        raise Notification::Error, response['error'] if response['ok'] == false

        response
      rescue Notification::Error => e
        puts "Slack error: \n\t#{e.message}"
      end
    end

    def backup_notification(result, title, content, notification_level)
      return if @slack_secret.nil? || @slack_channel.nil?
      return if notification_level == 'error' && result

      begin
        res = @conn.post('chat.postMessage') do |req|
          req.body = {
            channel: @slack_channel,
            blocks: [
              {
                type: 'header',
                text: {
                  type: 'plain_text',
                  text: title || "#{Rails.env} Message",
                  emoji: true
                }
              },
              {
                type: 'section',
                text: {
                  type: 'mrkdwn',
                  text: content || 'No content'
                }
              }
            ]
          }.to_json
        end
        response = JSON.parse(res.body)
        raise Notification::Error, response['error'] if response['ok'] == false

        response
      rescue Notification::Error => e
        puts "Slack error: \n\t#{e.message}"
      end
    end
  end
end
