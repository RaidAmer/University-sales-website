require "open-uri"
require "marcel"

user1 = User.find_or_initialize_by(uuid: "U00828281")
user1.assign_attributes(
  password: "123456",
  password_confirmation: "123456",
  first_name: "Admin",
  last_name: "Control",
  email: "Admin@gmail.com",
  approved: true,
  admin: true
)
user1.save!

categories = [
  {
    name:        'Arts',
    description: 'This is Art!',
    is_featured: false,

    icon:        'Art.jpg',
    products:    [
      { name: 'Face', price: '12', image: 'Face.jpg', status: 'Active', description: 'A picture of a face!', user: user1 },
      { name: 'Paintbrushes', price: '8', image: 'Paintbrushes.jpg', status: 'Active', description: 'Some Paintbrushes', user: user1 }]
  },
  {
    name:        'Crafts',
    description: 'These are Crafts',
    is_featured: false,
    icon:        'Craft.jpg',
    products:    [
      { name: 'Coffee cup', price: '22', image: 'Coffee.webp', status: 'Active', description: 'A cup to drink out of', user: user1 },
      { name: 'Ring', price: '150', image: 'Ring.webp', status: 'Active', description: 'A nice ring', user: user1 }

    ]
  }
]

categories.each do |cat_data|

  category = Category.find_or_initialize_by(name: cat_data[:name])
  category.assign_attributes(
    description: cat_data[:description],
    is_featured: cat_data[:is_featured]
  )
  category.save!

  # Attach category image
  cat_image_path = Rails.root.join("app/assets/images/categories/#{cat_data[:icon]}")

  file_data = File.binread(cat_image_path)
  category.icon.attach(
    io:           StringIO.new(file_data),
    filename:     cat_data[:icon],
    content_type: Marcel::MimeType.for(StringIO.new(file_data), name: cat_data[:icon])
  )

  # Seed products
  cat_data[:products].each do |prod_data|
    product = Product.find_or_initialize_by(
      name: prod_data[:name],
      category_id: category.id,
      user_id: prod_data[:user].id
    )
    product.assign_attributes(
      price: prod_data[:price],
      status: prod_data[:status],
      description: prod_data[:description],
      user: prod_data[:user]
    )

    unless product.image.attached?
      prod_image_path = Rails.root.join("app/assets/images/products/#{prod_data[:image]}")
      file_data = File.binread(prod_image_path)
      product.image.attach(
        io:           StringIO.new(file_data),
        filename:     prod_data[:image],
        content_type: Marcel::MimeType.for(StringIO.new(file_data), name: prod_data[:image])
      )
    end

    product.save!
  end

end
