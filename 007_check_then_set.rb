Order = Struct.new(:amount, :status) do
  def pending?
    status == 'pending'
  end

  def collect_payment
    puts "Collecting payment..."
    self.status = 'paid'
  end
end

# ------ main ------

order = Order.new(100.00, 'pending')

5.times.map do
  Thread.new do
    if order.pending? # check
      order.collect_payment # set
    end
  end
end.each(&:join)

