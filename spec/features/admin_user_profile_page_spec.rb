require 'rails_helper'

describe 'As an admin user' do
  describe  'when I visit a default user profile page' do
    it 'should see the same information that a user sees' do
      user_1 = create(:user)
      user_2 = create(:admin)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_2)

      visit admin_user_path(user_1)

      expect(page).to have_content(user_1.name)
      expect(page).to have_content(user_1.street)
      expect(page).to have_content(user_1.city)
      expect(page).to have_content(user_1.state)
      expect(page).to have_content(user_1.zip)
      expect(page).to have_content(user_1.email)

      expect(page).to have_link('Edit Profile')
      expect(page).to_not have_link("My Items")

      expect(page).to_not have_content(user_1.password)
    end
  end

  describe  'when I visit a merchant user profile page' do
    it 'should see the same information that a user sees' do
      user_1 = create(:merchant)
      user_2 = create(:admin)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_2)

      visit admin_user_path(user_1)

      expect(page).to have_content(user_1.name)
      expect(page).to have_content(user_1.street)
      expect(page).to have_content(user_1.city)
      expect(page).to have_content(user_1.state)
      expect(page).to have_content(user_1.zip)
      expect(page).to have_content(user_1.email)

      expect(page).to have_link('My Items')
      expect(page).to_not have_link("Edit Profile")

      expect(page).to_not have_content(user_1.password)
    end
  end
end