class HelloWorld
  attr_accessor :greet, :name

  def initialize(greet = 'Hello', name = 'World')
    @greet = greet
    @name = name
  end

  def hello
    binding.pry
    puts "#{greet}, #{name}!"
  end
end

puts "Now?"
