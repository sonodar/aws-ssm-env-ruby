class Parameter
  attr_reader :name, :value
  def initialize(*args)
    @name = args[0]
    @value = args[1]
  end
end
