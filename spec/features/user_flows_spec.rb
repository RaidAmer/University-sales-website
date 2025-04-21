# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "Navigation from new_user to home", type: :feature do
  scenario "User clicks 'Back to Home' and is redirected to /home" do
    visit "/new_user"
    click_link "Back to Home"
    expect(current_path).to eq("/home")
  end
end
