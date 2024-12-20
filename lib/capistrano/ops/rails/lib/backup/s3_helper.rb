# frozen_string_literal: true

module Backup
  module S3Helper
    def get_delete_items(items, keep)
      items.slice(keep..-1)
    end

    def get_months(all_items)
      all_items.reverse.map { |m| m[:last_modified].strftime('%Y-%m') }
    end

    def get_old_months(months)
      months.uniq.reject { |m| m == Time.now.strftime('%Y-%m') }
    end

    def get_current_month(all_items)
      all_items.select { |item| item[:last_modified].strftime('%Y-%m') == Time.now.strftime('%Y-%m') }
    end

    def get_items_by_month(all_items, month)
      all_items.select { |item| item[:last_modified].strftime('%Y-%m') == month }
    end

    def calculate_total_size(folder_path)
      total_size = 0
      Find.find(folder_path) do |file_path|
        total_size += File.size(file_path) unless File.directory?(file_path)
      end
      total_size
    end

    def calculate_chunk_size(total_size)
      max_chunks = 10_000
      min_chunk_size = 50 * 1024 * 1024 # 50MB
      max_chunk_size = 105 * 1024 * 1024 # 105MB
      chunk_size = [total_size / max_chunks, min_chunk_size].max
      [chunk_size, max_chunk_size].min
    end
  end
end
