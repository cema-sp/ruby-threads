class Order
  attr_accessor :amount, :status

  def initialize(amount, status)
    @amount, @status = amount, status
    @mutex = Mutex.new
  end

  def pending?
    status == 'pending'
  end

  def collect_payment
    @mutex.synchronize do
      puts 'Order: Collecting payment...'
      self.status = 'paid'
    end
  end
end

class Order2
  attr_accessor :amount, :status

  def initialize(amount, status)
    @amount, @status = amount, status
  end

  def pending?
    status == 'pending'
  end

  def collect_payment
    puts 'Order2: Collecting payment...'
    self.status = 'paid'
  end
end

# ------ main ------

order = Order.new(100.00, 'pending')
order2 = Order2.new(100.00, 'pending')

5.times.map do
  Thread.new do
    if order.pending?
      order.collect_payment
    end
  end
end.each(&:join)

mutex = Mutex.new
5.times.map do
  Thread.new do
    mutex.synchronize do
      if order2.pending?
        order2.collect_payment
      end
    end
  end
end.each(&:join)

