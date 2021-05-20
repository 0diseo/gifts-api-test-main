require 'rails_helper'

RSpec.describe "/users", type: :request do
  describe "POST /create" do
    context "with valid parameters" do
      it "create new user" do
        expect {
          post users_url params: {email: "user2@test.com", password: "password2"}
        }.to change(User, :count).by(1)
      end
    end

    it "renders a JSON response with the new user" do
      post users_url params: {email: "user2@test.com", password: "password2", age:27}
      expect(JSON.parse(response.body)["user"]).to include("email" => "user2@test.com", "age" => 27)
    end

    context "with invalid parameters" do
      it "does not create a new user" do
        expect {
          post users_url params: {email: "", password: ""}
        }.to change(Order, :count).by(0)
      end
    end

    it "renders a JSON response with errors for the new user" do
      post users_url params: {email: "", password: ""}
      expect(JSON.parse(response.body)).to eq( "error" => "Invalid email or password" )
    end
  end

  describe "login" do
    let!(:user) { create :user, email: "test@user.com", password: "123456", age: 30 }

    it "valid" do
      post login_url params: {email: "test@user.com", password: "123456"}
      expect(response).to be_successful
      expect(JSON.parse(response.body)["token"].present?).to eq true
    end

    it "invalid" do
      post login_url params: {email: "test@user.com", password: "no valid"}
      expect(JSON.parse(response.body)).to eq "error" => "Invalid email or password"
    end
  end
end
