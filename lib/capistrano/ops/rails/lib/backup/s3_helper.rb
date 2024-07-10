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
  end
end
