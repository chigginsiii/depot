class Cart < ActiveRecord::Base
  has_many :line_items, dependent: :destroy

  # build the item if it's new, increment the quantity if it's not
  def add_product(product_id)
    current_item = line_items.find_by(product_id: product_id)
    if current_item
      current_item.quantity += 1
    else
      current_item = line_items.build(product_id: product_id)
    end
    current_item
  end

  def total_price
    line_items.to_a.sum { |i| i.total_price }
  end
  
end
