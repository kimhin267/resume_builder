class Box
	def initialize (w,h)
		@width, @height = w,h
	end

	def width
		@width
	end

	def height
		@height
	end

	def setwidth=(x)
		@width = x
	end

	def setheight=(x)
		@height = x
	end
end

box = Box.new(10,10)

box.setheight = "asdf"
box.setwidth = 20

x = box.width()
y = box.height()

puts "x: #{x} and y: #{y}"
