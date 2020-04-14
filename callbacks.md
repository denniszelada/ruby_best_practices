# Active Records Callbacks

> A good callback is a great solution for:
  | Nothing complicated, for update some values

Let's refactor a red callback, like sending an email after saving, because we can trigger the email in any case,
like when we save something from the console, or some rake task can trigger the save, and send an email to a lot of people.

Example on how to refactor this cases

## Before 
  
```ruby
class Order < ActiveRecord
after_save :send_confirmation_email

private

def send_confirmation_email
  OrderMailer.confirmation(self).deliver
end
```

## After

```ruby
class OrdersController < ApplicationController
  def create
    @order = build_order
    @order.user = current_user
    
    if @order.save
      redirect_to @order
     else
      render "new"
     end
  end
  
  def new
    @order = Order.new
  end
  
  private
  
  def build_order
    ConfirmingOrder.new(
      Order.new(order_params)
    )
  end
  
  class ConfirmingOrder < SimpleDelegator
    def save
      if __getobj__.save
        OrderMailer.confirmation(self).deliver
      end
    end
  end

end
```

## Pros: 
* API stays the same
* Composes
