# frozen_string_literal: true

module Notification
  class Webhook
    require 'faraday'
    require 'openssl'
    require 'json'

    def initialize
      @webhook_url = ENV['WEBHOOK_URL']
      @secret = ENV['WEBHOOK_SECRET']
      @conn = Faraday.new(url: @webhook_url) do |faraday|
        faraday.headers['Content-Type'] = 'application/json'
      end
    end

    def generate_signature(payload_body)
      "md5=#{OpenSSL::HMAC.hexdigest('md5', ENV['WEBHOOK_SECRET'], payload_body)}"
    end

    def backup_notification(result, webhook_data, _notification_level)
      return if @webhook_url.nil? || @secret.nil?
      return if result && notification_level == 'error'

      @date = webhook_data[:date]
      @database = webhook_data[:database]
      @backup_path = webhook_data[:backup_path]

      @data = {
        domain: ENV['DEFAULT_URL'] || "#{@database} Backup",
        backupPath: result ? @backup_path : nil,
        backupDate: @date
      }.to_json

      begin
        @response = @conn.post do |req|
          req.headers['x-hub-signature'] = generate_signature(@data.to_s)
          req.body = @data
        end

        @response.to_hash
      rescue StandardError => e
        puts "Webhook error: \n\t#{e.message}"
      end
    end
  end
end
