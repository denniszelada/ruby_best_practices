# Restful Routes

> A good restful route looks like this:
```ruby
# noun#verb
# users#show
```

> A non good restul route looks like this:
```ruby
# noun#verb_noun
# users#make_admin
```

> In this case probably the last noun want to be a first citizen route, let's see an example

```ruby
# Old implementation

Rails.application.routes.draw do
  resources :users, only: [:show] do
    put :make_admin, on: member
    put :remove_admin, on: member
  end
  
  resource :orders, only: [:show, :update]
end

# The specs
require "rails_helper"

feature "Change user's admin status" do
  scenario "promote to admin" do
    user = create(:user, admin: false)
    
    visit_user_path(user)
    click_button "Promote to admin"
    
    expect(page).to have_text("User is an admin")
  end
  
  scenario "demote from admin" do
    user = create(:user, admin: true)
    
    visit user_path(user)
    click_button "Demote"
    
    expect(page).to have_text("User is not an admin")
  end
end

# The view
<h1>User management</h1>

<h2>Admin status</h2>

<% if @user.admin? %>
  <p>User is an admin</p>
  <%= button_to "Demote", remove_admin_user_path(@user), method: :put %>
<% else %>
  <p>User is not admin</p>
  <%= button_to "Promot to admin", make_admin_user_path(@user), method: :put%>
<% end %>


```

```ruby
# New implementation

Rails.application.routes.draw do
  resources :users, only: [:show] do
    resources :admin, only: [:create, :destroy]
  end
  
  resource :orders, only: [:show, :update]
end

# The specs
require "rails_helper"

feature "Change user's admin status" do
  scenario "promote to admin" do
    user = create(:user, admin: false)
    
    visit_user_path(user)
    click_button "Promote to admin"
    
    expect(page).to have_text("User is an admin")
  end
  
  scenario "demote from admin" do
    user = create(:user, admin: true)
    
    visit user_path(user)
    click_button "Demote"
    
    expect(page).to have_text("User is not an admin")
  end
end

# The view
<h1>User management</h1>

<h2>Admin status</h2>

<% if @user.admin? %>
  <p>User is an admin</p>
  <%= button_to "Demote", user__admin_path(@user), method: :delete %>
<% else %>
  <p>User is not admin</p>
  <%= button_to "Promot to admin", user_admin_path(@user)%>
<% end %>

# The controller
class AdminController < ApplicationController
  def create
    @user = User.find(params[:user_id])
    @user.update!(admin: true)
    redirect_to @user
  end
  
  def destroy
    @user = User.find(params[:user_id])
    @user.update!(admin: false)
    redirect_to @user
  end
end
```
