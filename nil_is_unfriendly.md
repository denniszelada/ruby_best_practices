# Nil is unfriendly

## Why not nil?
1. it's contaguios
2. nil adds no meaning

In this example we should verify nil in all the places,
even do this example is breaking the law of demeter.

```ruby
user.account.subsciption.plan.price
user.
  try(:account).
  try(:subscription).
  try(:plan).
  try(:price)
```

This fix the law of demeter using delegators
```ruby
user.price

class User
  delegate :price,
  to: :account,
  allow_nil: true
end

class Account
  delegate :price,
  to: subsciption,
  allo_nil: true
end

# An many more!
```

By at the end of the day nil still bite you, because you need to be careful
with nil all over the place

and at the end of the day will still get
```ruby
  user.price
  # => nil
```
But what does this mean?
* Doesn't have a price?
* It's a free account?
* It's an error? "probably"

In ruby we talk a lot about duck typing

nil is not a duck, so every time you return nil you are violating the duck
typing of ruby.

In this example we have two subscriptions (ducks)

```ruby
class PlanSubscription
  def price
    plan.price
  end
end

class MeteredSubscription
  COST_PER_KILOBYTE = 0.01

  def price
    COST_PER_KILOBYTE * kilobytes_used
  end
end

# You can chage any type of subscription
class Account
  def charge_for_subscription
    credit_card.charge(subscription.price) # price => quack
  end
end

# Unless you get nil
class Account
  def charge_for_subscription
    credit_card.charge(nil)
  end
end

# Then you need to be carefull for this
class Account
  def charge_for_subscription
    price = subscription.try(:price) || 0
    credit_card.charge(price)
  end
end
```

## Solutions
Null Object
* Remove conditional logic
* Encapsulate logic around nothingness
* Polymorphism, duck typing
* When nil is always handled the same

Note: Avoid adding null to the name of the class because doesn't add any
logic

```ruby
class Account
  def charge_for_subscription
    credit_card.charge(subscription.price) # price => quack
  end
end

class FreeSubscription
  def price
    0
  end
end
```

## Exceptions
* Removes conditional logic
* Avoid invalid situations
* Prevent hard-to-debug issues
* When nil is unexpected

One example of when to avoid NullObjects is when find yourself asking questions
as this

```ruby
if subscription.is_a?(FreeSubscription)
  # Violation of tell don't ask
end
```
## The second way to solve nil is unfriendly is raising an exception
But it's not a good idea rescue NoMethodError on production.

```ruby
Account.find_each do |account|
  begin
    account.charge_for_subscription
  rescue NoMethodError => exception
    Airbrake.norigy(exception)
  end
end
```

So this is a better solution, if we know that doesn't exist a credit card
```ruby
class Account < ActiveRecord::Base
  class NoCreditCardError < StandardError
  end

  def credit_card
    super || raise NoCreditCardError
  end
end
```

## The third idea "Maybe"
* Forces conditional logic
* Avoid invalid scenarios
* Nils need individual handling

```ruby
class Account
  def status
    last_charge = subscription.last_charge
    "Charged #{last_charge.amoun}" \
      "on #{last_charge.created_at}"
  end
end

# But if there's no subscription this will blow up
class Account
  def status
    last_charge = nil
    "Charged #{last_charge.amoun}" \
      "on #{last_charge.created_at}"
  end
end

# So we need to force the conditional logic, even do in this case we still
need to check for all the cases

class Account
  def status
    if last_charge = subsciption.last_charge # last_charge => quack?
      "Charged #{last_charge.amoun}" \
        "on #{last_charge.created_at}"
    else
      'Pending'
    end
  end
end
```

