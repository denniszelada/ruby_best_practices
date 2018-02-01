# Tell Don't Ask, it's an active directory principle
# Instead of having a dialogue back and forward with your objects, you provide
# simple consice commands, like whatever you are save yourself
# Good OOP is about telling objects what you want done, not querying an
# object and acting on its behalf
# To identify if you are violating tell don't ask, it's when you mixed methods, 
# like mixing this two type of methods:
#   * Query Methods: This methods make some kind of question or return some
#     value.
#   * Command Methods: This doesn't return nothing like: user.save
# Example Not so good
<% if current_user.admin? %>
  <%= current_user.admin_welcome_message %
<% else %>
  <%= current_user.user_welcome_message %>
<% end %>

# Better
<%= current_user.welcome_message %>

# Example not so good
def check_for_overheating(system_monitor)
  if system_monitor.temperature > 100
    system_monitor.sound_alarms
  end
end

# Better
system_monitor.check_for_overheating

class SystemMonitor
  def check_for_overheating
    if temperature > 100
      sound_alarms
    end
  end
end

# Example not so good 
class Post
  def send_to_feed
    if User.is_a?(TwitterUser)
      user.send_to_feed(contents)
    end
  end
end

#Better we can use polymorphism
class Post
  def send_to_feed
    user.send_to_feed(contents)
  end
end

class TwitterUser
  def send_to_feed(contents)
    twitter_client.post_to_feed(contents)
  end
end

class EmailUser
  def send_to_feed(contents)
    # no-op.
  end
end


# Not so good, in this case we are asking the street name to the address
def street_name(user)
  if user.address
    user.address.street_name
  else
    'No street name on file'
  end
end

# Better
def street_name(user)
  user.address.street_name
end

class User
  def address
    @address || NullAddress.new
  end
end

class NullAddress
  def street_name
    'No street name on file'
  end
end

# Example in which case a Query methods could consider ok, is this one in the
# sense that we should follow also the separation of conserns, meaningh MVC.
#
<% if current_user.sigend_in? %>
  <%= link_to 'Sign out', sign_out_path %>
<% else %>
  <%= link_to 'Sign in', sign_in_path %>
<% end%>

# Example of violating tell don't ask, mixing the query methods and the
# command methods

if user.password.present?
  user.save!
else
  user.errors.add :password, "can't be blank"
end

# Example of a Mixed Methods in which case it's ok, because the Rails api is
# used on this way

if @user.save
  ConfirmationMailer.confirmation(@user).deliver
  redirect_to root_url
else
  render 'new'
end
