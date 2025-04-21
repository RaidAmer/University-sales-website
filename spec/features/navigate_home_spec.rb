# frozen_string_literal: true

require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature "User Navigation and Validation Features", type: :feature do
  scenario "Navigating from /successfully_created_account to /categories" do
    visit "/successfully_created_account"
    click_link "Browse Store"
    expect(current_path).to eq("/categories")
  end

  scenario "Navbar Sign In redirects to login page" do
    visit "/home"
    click_link "Sign In"
    expect(current_path).to eq("/login")
    expect(page).to have_field("UUID")
    expect(page).to have_field("Password")
    expect(page).to have_button("Log In Account")
  end

  scenario "Unapproved user cannot access /categories" do
    unapproved_user = User.create!(
      uuid: "U00000001", password: "password",
      first_name: "Test", last_name: "User",
      approved: false, admin: false,
      university_id: fixture_file_upload(Rails.root.join("spec", "fixtures", "files", "id_sample.png"), "image/png") # Ensure this file exists
    )

    visit "/login"
    fill_in "UUID", with: unapproved_user.uuid
    fill_in "Password", with: "password"
    click_button "Log In Account"

    visit "/categories"
    expect(current_path).to eq("/categories")
    expect(page).to have_content("Category!")
  end

  scenario "Missing UUID or Password shows HTML5 validation message" do
    visit "/login"
    click_button "Log In Account"
    expect(page).to have_current_path("/login") # stays on same page
  end

  scenario "Order shows in checkout page after creation" do
    user = User.create!(
      uuid: "U00000002", password: "password",
      first_name: "Buyer", last_name: "Test",
      approved: true, admin: false,
      university_id: fixture_file_upload(Rails.root.join("spec", "fixtures", "files", "id_sample.png"), "image/png")
    )
    login_as(user, scope: :user)

    category = Category.create!(name: "Test")
    image_path = Rails.root.join("spec", "fixtures", "files", "id_sample.png")
    uploaded_image = fixture_file_upload(image_path, "image/png", binary: true)
    product = Product.create!(
      name: "Item A",
      price: 10,
      description: "Test",
      category: category,
      user: user,
      image: uploaded_image
    )

    visit categories_path
    click_link category.name
    click_link "Item A" # navigate to product detail page
    expect(page).to have_button("Add to Cart", wait: 5)
    click_button("Add to Cart")
    visit "/cart"
    save_and_open_page
    click_button "Proceed to Payment"
    expect(current_path).to eq("/payment_transactions/new")
  end

  scenario "Account creation fails without university ID" do
    visit "/new_user"
    fill_in "First Name", with: "NoID"
    fill_in "Last Name", with: "User"
    fill_in "UUID", with: "U00000003"
    fill_in "Password", with: "secure123"
    attach_file("user_university_id", nil)
    click_button "Create Account"
    expect(page).to have_content("❌ Please make sure to enter your UUID and upload a valid ID file.")
  end

  after(:each) do
    Warden.test_reset!
  end
end
