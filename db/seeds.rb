city    = 'Brechin'
country = 'United Kingdom'
areas   = [
  "Brechin"
]

areas.each do |area|
  Area.create_with(city: city, country: country).find_or_create_by(name: area)
end

categories = [
  "Childhood",
  "Education",
  "Environment",
  "Events",
  "Family Life",
  "Fashion",
  "Food and Drink",
  "Health",
  "Home",
  "Places",
  "Sport & Leisure",
  "Technology",
  "Travel",
  "Work"
]

categories.each do |c|
  Category.find_or_create_by(name: c)
end
