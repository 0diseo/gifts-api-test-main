FactoryBot.define do
  factory :recipient do
    user_id { "" }
    school_id {""}
    order_id {""}
    gift { [] }
    address { "MyString" }
  end
end
