# frozen_string_literal: true

module Notification
  class Webhook
    require 'uri'
    require 'net/http'
    require 'net/https'
    require 'openssl'
    require 'json'

    def initialize
      @webhook_url = ENV['WEBHOOK_URL']
      @secret = ENV['WEBHOOK_SECRET']
    end

    def generate_signature(payload_body)
      "md5=#{OpenSSL::HMAC.hexdigest('md5', ENV['WEBHOOK_SECRET'], payload_body)}"
    end

    def backup_notification(result, date, database, backup_path, _notification_level)
      return if @webhook_url.nil? || @secret.nil?
      return if result && ENV['NOTIFICATION_LEVEL'] == 'error'

      data = {
        domain: ENV['DEFAULT_URL'] || "#{database} Backup",
        backupPath: result ? backup_path : nil,
        backupDate: date
      }.to_json

      uri = URI.parse(@webhook_url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = uri.scheme == 'https'
      request = Net::HTTP::Post.new(uri.path.empty? ? '/' : uri.path,
                                    { 'Content-Type' => 'application/json', 'x-hub-signature' => generate_signature(data.to_s) })
      request.body = data.to_s
      begin
        response = https.request(request)
        response.to_hash
      rescue StandardError => e
        puts "Webhook error: \n\t#{e.message}"
      end
    end
  end
end
