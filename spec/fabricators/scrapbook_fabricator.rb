Fabricator(:scrapbook) do
  id          { sequence(:id, 1) }
  user
  title       { Faker::Product.product_name }
  description { Faker::Lorem.words(rand(50)).join(' ') }
  updated_at  { rand(10).to_i.days.ago }
end

