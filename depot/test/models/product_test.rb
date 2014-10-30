require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products

  test "product attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test "product prices myst be positive" do
    product = Product.new(
      title: 'My Book Title',
      description: 'yyy',
      image_url: 'zzz.jpg',
    )
    product.price = -1
    assert product.invalid?
    assert_equal ['must be greater than or equal to 0.01'], product.errors[:price]

    product_price = 0
    assert product.invalid?
    assert_equal ['must be greater than or equal to 0.01'], product.errors[:price]

    product.price = 1
    assert product.valid?
  end

  def new_product(image_url)
    Product.new(
      title: 'My Book Title',
      price: 1,
      description: 'yyy',
      image_url: image_url
    )
  end

  test "image url" do
    ok  = %w{fred.gif fred.jpg fred.png FRED.JPG FRED.Jpg http://a.b.c/x/t/c/fred.gif }
    bad = %w{fred.doc fred.gif.more fred.gif/more}
    ok.each do |name|
      assert new_product(name).valid?, "#{name} should be valid"
    end
    bad.each do |name|
      assert new_product(name).invalid?, "#{name} should be invalid"\
    end
  end

  test "product is not valud without a unique title" do
    # this should already be loaded in test db from test/fixtures/products.yml
    product = Product.new(
      title: products(:ruby).title,
      description: 'yyy',
      price: 1,
      image_url: "fred.gif"
    )

    assert product.invalid?
    # preview of i18n goodness
    assert_equal [I18n.translate('errors.messages.taken')], product.errors[:title]
  end

end
