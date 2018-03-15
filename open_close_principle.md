# Open Close Principle
> This principle consider the idea of immutable structures, which make the 
question what if once I wrote code I never change it?
>  The formal definition is "It's open for extension but close for modification"

Let's see a couple of examples on how to follow this rule, and we can follow
this by:
Abstraction

```ruby
# Disobeys OCP because in this case if we want to change the way payment users
# we need to open the class Stripe
class Purchase
  def charge_user!
    Stripe.charge(user: user, amount: amount)
  end
end

# Follows OCP by depending on an abstraction
# this follow OCP becuase in the case we want to change the charge user
# we can just extend the payment_processor

class Purchase
  def charge_user!(payment_processor)
    payment_processor.charge(user: user, amount: amount)
  end
end


# Disobeys OCP by checking type, and contains an infectious case statement
# In this case if we change the way we print a document we need to change
# everything and also if we want to add a new print type we are modifying it.

class Printer
  def initialize(item)
    @item = item
  end

  def print
    thing_to_print = case @item
    when Text
      @item.to_s
    when Image
      @item.filename
    when Document
      @item.formatted
    end

    sent_to_printer(thing_to_print)
  end
end

# Follow OCP by using polymorphism
class Printer
  def initialize(item)
    @item = item
  end

  def print
    send_to_printer(@item.printable_representation)
  end
end

# Disobeys OCP
class Unsubscriber
  def unsubscribe!
    SubscriptionCanceller.new(user).process
    CancellationNotifier.new(user).notify
    CampfireNotifier.announce_sad_news(user)
  end
end

# Follow OCP
class UnsubscriptionCompositeObserver
  def initialize(observers)
    @observers = observers
  end

  def notify(user)
    @observers.each do |observer|
      observer.notify(user)
    end
  end
end

class Unsubscriber
  def initialize(observer)
    @observer = observer
  end

  def unsubscribe!(user)
    observer.notify(user)
  end
end


# Other wins:
# * Free extension point: order
# * Unsubscriber is ignoratn ofhow many observers are involved
# * One place for handling failures, aggregations, etc
# * Can create nested structures of composites
```
