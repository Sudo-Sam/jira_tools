require 'rein'
class Obj1
  attr_accessor :mailbox, :var1

  include Rein
  def color(name)
    @mailbox = name
  end
  def initialize
    @var1=1
  end
end

rule = Rein::RuleEngine.new 'hands.yaml'
obj = Obj1.new

rule.fire(obj)
puts obj.mailbox