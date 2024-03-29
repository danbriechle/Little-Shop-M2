require 'rails_helper'



RSpec.describe "When a user visitor visits their cart show page with items in cart" do
  include ActionView::Helpers::NumberHelper

  it "displays the items in their cart" do
    user_1 = User.create(name: 'User One', street: 'Street One', city: 'City One', state: 'State1',
    zip: '12334', email: 'email1@aol.com', password: 'password1', role: 0, enabled: true)
    #Merchant User
    merchant = User.create(name: 'User Five', street: 'Street Five', city: 'City Five', state: 'State5',
    zip: '54321', email: 'email5@aol.com', password: 'password5', role: 1, enabled: true)
    #Item belonging to Mercant
    item_1 = Item.create(name: 'IBM PCXT 5160', user: merchant, inventory: 3,
    current_price: 399500, enabled: true, image_link: 'https://picsum.photos/g/200/300', description: 'Yesterday in personal computing technology')
    item_2 = Item.create(name: 'IBM PCXT 5161', user: merchant, inventory: 3,
    current_price: 400000, enabled: true, image_link: 'https://picsum.photos/5472/3648?image=1083', description: 'The latest in personal computing technology')

    visit items_path

    within "#item-#{item_1.id}" do
      click_button('Add item')
    end
    expect(page).to have_content("Cart: 1")
    within "#item-#{item_2.id}" do
      click_button('Add item')
      click_button('Add item')
    end

    expect(page).to have_content("Cart: 3")

    quantity_1 = 1
    quantity_2 = 2
    subtotal_1 = (item_1.current_price * quantity_1)/100
    subtotal_2 = (item_2.current_price * quantity_2)/100

    visit cart_path


    within "#item-#{item_1.id}" do
      expect(page).to have_content(item_1.name)
      expect(page).to have_content(item_1.user.name)
      expect(page).to have_css("img[src*='#{item_1.image_link}']")
      expect(page).to have_content(number_to_currency(item_1.current_price/100))
      expect(page).to have_content("Quantity: #{quantity_1}")
      expect(page).to have_content("Subtotal: #{number_to_currency(subtotal_1)}")
      expect(page).to_not have_content(item_2.name)
    end

    within "#item-#{item_2.id}" do
      expect(page).to have_content(item_2.name)
      expect(page).to have_css("img[src*='#{item_2.image_link}']")
      expect(page).to have_content(item_2.user.name)
      expect(page).to have_content(number_to_currency(item_2.current_price/100))
      expect(page).to have_content("Quantity: #{quantity_2}")
      expect(page).to have_content("Subtotal: #{number_to_currency(subtotal_2)}")

      expect(page).to_not have_content(item_1.name)
    end

    expect(page).to have_content("Grand Total: #{number_to_currency(subtotal_1 + subtotal_2)}")
    expect(page).to have_link("Empty Cart")
  end

  it 'allows a visitor to empty their cart' do
    merchant = create(:merchant)
    item_1 = create(:item, user: merchant)
    item_2 = create(:item, user: merchant)
    item_3 = create(:item, user: merchant)

    visit items_path
    within "#item-#{item_1.id}" do
      click_button 'Add item'
      click_button 'Add item'
    end
    within "#item-#{item_2.id}" do
      click_button 'Add item'
    end
    within "#item-#{item_3.id}" do
      click_button 'Add item'
    end

    visit cart_path

    click_on "Empty Cart"

    expect(current_path).to eq(cart_path)
    within "#nav" do
      expect(page).to have_content("Cart: 0")
    end
    expect(page).to_not have_content(item_1.name)
    expect(page).to_not have_content(item_2.name)
    expect(page).to_not have_content(item_3.name)
    expect(page).to_not have_content(item_1.description)
    expect(page).to_not have_content(item_2.description)
    expect(page).to_not have_content(item_3.description)
    expect(page).to have_content("Grand Total: $0.00")
  end

  it 'allows a registered user to empty their cart' do
    user = create(:user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    merchant = create(:merchant)
    item_1 = create(:item, user: merchant)
    item_2 = create(:item, user: merchant)
    item_3 = create(:item, user: merchant)

    visit items_path
    within "#item-#{item_1.id}" do
      click_button 'Add item'
      click_button 'Add item'
    end
    within "#item-#{item_2.id}" do
      click_button 'Add item'
    end
    within "#item-#{item_3.id}" do
      click_button 'Add item'
    end

    visit cart_path

    click_on "Empty Cart"

    expect(current_path).to eq(cart_path)
    within "#nav" do
      expect(page).to have_content("Cart: 0")
    end
    expect(page).to_not have_content(item_1.name)
    expect(page).to_not have_content(item_2.name)
    expect(page).to_not have_content(item_3.name)
    expect(page).to_not have_content(item_1.description)
    expect(page).to_not have_content(item_2.description)
    expect(page).to_not have_content(item_3.description)
    expect(page).to have_content("Grand Total: $0.00")
  end

  it 'allows registered users to check out' do
    user = create(:user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    item_1 = create(:item)
    item_2 = create(:item)

    visit items_path
    within "#item-#{item_1.id}" do
      click_on 'Add item'
    end
    within "#item-#{item_2.id}" do
      click_on 'Add item'
    end

    visit cart_path
    click_on("Check Out")

    order = Order.last
    expect(order.items).to eq([item_1, item_2])
    expect(order.status).to eq('pending')

    expect(current_path).to eq(profile_path)
    expect(page).to have_content("Your order has been created!")
    expect(page).to have_content("Order: #{order.id}")
    expect(page).to have_content("Status: pending")
    expect(page).to have_content("Item count: #{order.item_quantity}")
    expect(page).to have_content("Grand total: #{number_to_currency(order.grand_total/100)}")
    expect(page).to have_content("Cart: 0")
  end

  it 'allows user to a user to remove and adjust item quantity in their cart' do
    user = create(:user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    merchant = create(:merchant)
    item_1 = create(:item, user: merchant, inventory: 2)
    item_2 = create(:item, user: merchant, inventory: 1)
    item_3 = create(:item, user: merchant, inventory: 1)

    visit items_path
    within "#item-#{item_1.id}" do
      click_button 'Add item'
    end
    within "#item-#{item_2.id}" do
      click_button 'Add item'
    end
    within "#item-#{item_3.id}" do
      click_button 'Add item'
    end

    visit cart_path

    within  "#item-#{item_3.id}" do
      click_on 'Remove item'
    end

    expect(page).to have_content("Cart: 2")
    expect(page).to have_content(item_2.name)
    expect(page).to have_content(item_1.name)
    expect(page).to_not have_content(item_3.name)

    within "#item-#{item_2.id}" do
      click_on 'Add one'
    end

    expect(page).to have_content("The merchant does not have enough inventory")

    within "#item-#{item_2.id}" do
      expect(page).to have_content("Quantity: 1")
    end

    within "#item-#{item_1.id}" do
      click_on 'Add one'
    end

    within "#item-#{item_1.id}" do
      expect(page).to have_content("Quantity: 2")
    end

    expect(page).to have_content(item_2.name)
    expect(page).to have_content(item_1.name)
    expect(page).to_not have_content(item_3.name)
  end
end
