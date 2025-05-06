# frozen_string_literal: true

require 'open-uri'
require 'marcel'

user1 = User.find_or_initialize_by(uuid: 'U00828281')
user1.assign_attributes(
  password:              '123456',
  password_confirmation: '123456',
  first_name:            'Admin',
  last_name:             'Control',
  email:                 'Admin@gmail.com',
  approved:              true,
  admin:                 true
)
user1.save!

categories = [
  {
    name:        'Arts',
    description: 'This is Art!',
    is_featured: false,

    icon:        'Art.jpg',
    products:    [
      { name: 'Face', price: '12', image: 'Face.jpg', status: 'Active', description: 'A picture of a face!',
user: user1 },
      { name: 'Paintbrushes', price: '8', image: 'Paintbrushes.jpg', status: 'Active',
description: 'Some Paintbrushes', user: user1 },
      { name: 'Red Paint', price: '5.99', image: 'red_paint.webp', status: 'Active', description: 'Red paint for painting!',
user: user1 },
      { name: 'Blue Paint', price: '5.99', image: 'acrylic_blue_paint.jpeg', status: 'Active',
description: 'Blue paint for painting!', user: user1 },
      { name: 'Yellow Paint', price: '5.99', image: 'yellow_paint.avif', status: 'Active',
description: 'Yellow paint for painting SpongeBob!', user: user1 },
      { name: 'Black Paint', price: '5.99', image: 'black_paint.avif', status: 'Active', description: 'Black paint for pirates!',
user: user1 },
      { name: 'White Paint', price: '5.99', image: 'white_paint.avif', status: 'Active', description: 'White paint to make pink!',
user: user1 },
      { name: 'Green Paint', price: '5.99', image: 'green_paint.avif', status: 'Active', description: 'Green paint to paint grass!',
      user: user1 },
      { name: 'Orange Paint', price: '5.99', image: 'orange_paint.avif', status: 'Active', description: 'Orange paint to paint oranges!',
      user: user1 },
      { name: 'Purple Paint', price: '5.99', image: 'purple_paint.webp', status: 'Active', description: 'Purple paint to paint something?',
      user: user1 },
      { name: 'Cyan Paint', price: '5.99', image: 'light_blue_paint.avif', status: 'Active', description: 'Cyan paint to paint the sky!',
      user: user1 },
      { name: 'Sketchbook', price: '7.99', image: 'sketch_book.jpg', status: 'Active', description: 'Sketchbook for drawing',
      user: user1 },
      { name: 'Canvases', price: '40.99', image: 'canvases.jpg', status: 'Active',
description: 'Canvases to paint on!', user: user1 },
      { name: 'Easel', price: '17.99', image: 'easel.avif', status: 'Active', description: 'Easel for painting!',
user: user1 }
    ]
  },
  {
    name:        'Crafts',
    description: 'These are Crafts',
    is_featured: false,
    icon:        'Craft.jpg',
    products:    [
      { name: 'Coffee cup', price: '22', image: 'Coffee.webp', status: 'Active', description: 'A cup to drink out of',
user: user1 },
      { name: 'Ring', price: '150', image: 'Ring.webp', status: 'Active', description: 'A nice ring', user: user1 },
      { name: 'Pottery Clay', price: '29.99', image: 'clay.jpeg', status: 'Active', description: 'Clay for pottery',
user: user1 },
      { name: 'Bug Crafts', price: '19.99', image: 'bug_crafts.jpg', status: 'Active',
description: 'Made some bug crafts', user: user1 },
      { name: 'Clay Cutter', price: '10.99', image: 'fishing_net_string_clay_cutter.jpg', status: 'Active',
description: 'For pottery, use this to cut clay', user: user1 },
      { name: 'Flower Craft', price: '6.99', image: 'flower_craft.jpg', status: 'Active', description: 'Flower crafts',
user: user1 },
      { name: 'Origami Fish', price: '2.99', image: 'origami_fish.jpg', status: 'Active',
description: 'Fish made using origami.', user: user1 },
      { name: 'Origami Paper', price: '12.99', image: 'origami_paper.jpg', status: 'Active',
description: 'Origami paper for origami.', user: user1 },
      { name: 'Potter\'s Wheel', price: '199.99', image: 'potters_wheel.jpg', status: 'Active', description: 'Potter\'s Wheel for anyone doing pottery.',
user: user1 },
      { name: 'Wood Hearts', price: '25.99', image: 'wood_hearts.jpg', status: 'Active',
description: 'Hearts made of wood.', user: user1 },
      { name: 'Crochet Frog', price: '1.99', image: 'crochet_frog.png', status: 'Active', description: 'Frog made of crochet.',
user: user1 },
      { name: 'Origami Tulip', price: '0.99', image: 'origami_tulip.webp', status: 'Active', description: 'Tulip made of origami.',
user: user1 }
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
      name:        prod_data[:name],
      category_id: category.id,
      user_id:     prod_data[:user].id
    )
    product.assign_attributes(
      price:       prod_data[:price],
      status:      prod_data[:status],
      description: prod_data[:description],
      user:        prod_data[:user]
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
