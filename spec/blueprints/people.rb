Person.blueprint do
  name
  salary
  age { (rand(70) + 10).to_i }
end