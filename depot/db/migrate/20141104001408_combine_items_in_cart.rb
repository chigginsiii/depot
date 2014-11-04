class CombineItemsInCart < ActiveRecord::Migration
  def up
    Cart.all.each do |cart|
      # group returns an association, sum returns { prod_id => quantity}
      sums = cart.line_items.group(:product_id).sum(:quantity)

      sums.each do |product_id, quantity|
        # if this has more than one of this product with quantity 1, combine
        # by deleting previous and replacing with one line item
        if quantity > 1
          cart.line_items.where(product_id: product_id).delete_all
          item = cart.line_items.build(product_id: product_id, quantity: quantity)
          item.save!
        end
      end

    end      
  end

  def down
    # for all line_items with quantity greater then 1, split then into singles
    LineItem.where("quantity > 1").each do |li|
      li.quantity.times do
        LineItem.create cart_id: li.cart_id, product_id: li.product_id, quantity: 1
      end
      li.destroy!
    end
  end

end
