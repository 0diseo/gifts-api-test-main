FactoryBot.define do
  factory :recipient do
    user_id { "" }
    school_id {""}
    order_id {""}
    gift { "MyString" }
    address { "MyString" }
  end
end
