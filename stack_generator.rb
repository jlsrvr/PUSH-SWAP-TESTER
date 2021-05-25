puts "Hi, I'm your stack generator!"
puts "How many numbers do you want?"
print '> '
size = gets.chomp.to_i
puts "Would you like these ordered:"
puts "1. Randomly"
puts "2. Ascendingly"
puts "3. Descendingly"
print '> '
order = gets.chomp&.to_i
if order == 2
  numbers = (-100..5000).to_a.sample(size).sort
elsif order == 3
  numbers = (-100..5000).to_a.sample(size).sort.reverse
else
  numbers = (-100..5000).to_a.sample(size)
end
p numbers.join(' ')
