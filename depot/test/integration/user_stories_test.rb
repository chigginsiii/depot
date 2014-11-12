require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  fixtures :products

  name = "Dave Thomas"
  address = "123 The Street"
  email = "dave@example.com"
  pay_type = "Check"

  test "buying a product" do
    LineItem.delete_all
    Order.delete_all
    ruby_book = products(:ruby)

    # user visits the site
    get "/"
    assert_response :success
    assert_template "index"

    # and selects a product to add to their cart
    xml_http_request :post, '/line_items', product_id: ruby_book.id
    assert_response :success

    cart = Cart.find(session[:cart_id])
    assert_equal 1, cart.line_items.size
    assert_equal ruby_book, cart.line_items[0].product

    # Then they check out:
    get "/orders/new"
    assert_response :success
    assert_template "new"

    # fill out the order form and submit...
    post_via_redirect '/orders', order: {
      name: name,
      address: address,
      email: email,
      pay_type: pay_type
    }

    assert_response :success
    assert_template "index"

    cart = Cart.find(session[:cart_id])
    assert_equal 0, cart.line_items.size

    # verify the order/items in the db
    orders = Order.all
    assert_equal 1, orders.size
    order = orders[0]

    assert_equal name, order.name
    assert_equal address, order.address
    assert_equal email, order.email
    assert_equal pay_type, order.pay_type

    assert_equal 1, order.line_items.size
    line_item = order.line_items[0]
    assert_equal ruby_book, line_item.product

    # verify the email contains what we think it does
    mail = ActionMailer::Base.deliveries.last
    assert_equal [email], mail.to
    assert_equal "Your Mom <depot@example.com>", mail[:from].value
    assert_equal "Pragmatic Store Order Confirmation", mail.subject

  end

end
