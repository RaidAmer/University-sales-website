
require "open-uri"
require "marcel"

# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user1 = User.create!(
  uuid: "U00828281",
  password: "123456",
  password_confirmation: "123456",
  first_name: "Ilham",
  last_name: "Dinle",
  email: "yhssein1@memphis.edu",
  approved: true,
  admin: true
)

categories = [
  {
    name: "Arts",
    description: "This is Art!",
    is_featured: false,
    icon: "Art.jpg",
    products: [
      { name: "Face", price: "12", image: "Face.jpg", status: "Active", description: "A picture of a face!", user: user1 },
      { name: "Paintbrushes", price: "8", image: "Paintbrushes.jpg", status: "Active", description: "Some Paintbrushes", user: user1 }
    ]
  },
  {
    name: "Crafts",
    description: "These are Crafts",
    is_featured: false,
    icon: "Craft.jpg",
    products: [
      { name: "Coffee cup", price: "22", image: "Coffee.webp", status: "Active", description: "A cup to drink out of", user: user1 },
      { name: "Ring", price: "150", image: "Ring.webp", status: "Active", description: "A nice ring", user: user1 }
    ]
  }
]

categories.each do |cat_data|
  category = Category.create!(
    name: cat_data[:name],
    description: cat_data[:description],
    is_featured: cat_data[:is_featured]
  )

  # Attach category image
  cat_image_path = Rails.root.join("app/assets/images/categories/#{cat_data[:icon]}")

    file_data = File.binread(cat_image_path)
    category.icon.attach(
      io: StringIO.new(file_data),
      filename: cat_data[:icon],
      content_type: Marcel::MimeType.for(StringIO.new(file_data), name: cat_data[:icon])
    )

  # Seed products
  cat_data[:products].each do |prod_data|
    product = category.products.build(
      name: prod_data[:name],
      price: prod_data[:price],
      status: prod_data[:status],
      description: prod_data[:description],
      user: prod_data[:user]
    )

    prod_image_path = Rails.root.join("app/assets/images/products/#{prod_data[:image]}")
      file_data = File.binread(prod_image_path)
      product.image.attach(
        io: StringIO.new(file_data),
        filename: prod_data[:image],
        content_type: Marcel::MimeType.for(StringIO.new(file_data), name: prod_data[:image])
      )

    product.save!
  end
end