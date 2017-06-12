module Spina::Shop
  class TaxGroup < ApplicationRecord
    # All product items that belong to this tax group
    has_many :product_items, dependent: :restrict_with_exception
    has_many :delivery_options, dependent: :restrict_with_exception

    has_many :tax_rates, dependent: :destroy

    validates :name, presence: true

    # Get the rate based on the order
    # 
    # Priority:
    # 1. Get rate by customer group
    # 2. Get rate by zone
    # 3. Default Spina config
    def tax_rate_for_order(order)
      rate_by_zone(order.zone).try(:rate) || Spina::Shop.config.default_tax_rate
    end

    # Get the tax code based on the order
    # 
    # Priority:
    # 1. Get code by customer group
    # 2. Get code by zone
    # 3. Default Spina config
    def tax_code_for_order(order)
      rate_by_zone(order.zone).try(:code) || Spina::Shop.config.default_tax_code
    end

    private

      # Get the correct rate by zone
      # 
      # Priority:
      # 1. Match zone
      # 2. Match parent of zone
      # 3. Default zone
      def rate_by_zone(zone)
        tax_rates.where(tax_rateable: zone).first || 
        tax_rates.where(tax_rateable: zone.parent).first || 
        tax_rates.default_rate.first
      end

  end
end