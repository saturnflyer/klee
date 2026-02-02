# frozen_string_literal: true

class User
  def create_subscription(plan)
    subscription = Subscription.new(plan)
    subscription.activate
  end

  def cancel_subscription
    subscription.deactivate
  end

  def subscription_active?
    subscription.active?
  end

  def find_orders
    orders.where(user: self)
  end
end

class Subscription
  attr_reader :plan, :user

  def initialize(plan)
    @plan = plan
  end

  def activate
    billing_service.start_billing(self)
  end

  def deactivate
    billing_service.stop_billing(self)
  end

  def active?
    status == :active
  end

  def renewal_date
    started_at + plan.duration
  end
end

class Order
  def create_invoice
    invoice = Invoice.new(self)
    invoice.generate
  end

  def find_line_items
    line_items.all
  end
end

class Invoice
  attr_reader :order

  def initialize(order)
    @order = order
  end

  def generate
    # Generate invoice
  end

  def get_total
    line_items.sum(&:amount)
  end
end
