require 'rails_helper'

RSpec.describe "/schools", type: :request do
  let!(:user) {create :user, email: "test@user.com", password: "123456", age: 30}
  let!(:school) { create :school, address:"street demo", name: "high school"}
  let!(:other_school) { create :school, address:"street demo", name: "other school"}

  before do
    post login_url params: {email: "test@user.com", password: "123456"}
    @token = JSON.parse(response.body)["token"]
  end

  after do
    user.destroy
    school.destroy
    other_school.destroy
  end

  describe "GET /index" do
    it "renders a successful response" do
      get schools_url, headers: authorization_header, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      get school_url(school), headers: authorization_header, as: :json
      expect(response).to be_successful
    end

    it "get the correct school" do
      get school_url(school), headers: authorization_header, as: :json
      expect(response.body).to eq school.to_json
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new School" do
        expect {
          post schools_url,
               params: { name: "high school", address: "some address" }, headers: authorization_header, as: :json
        }.to change(School, :count).by(1)
      end

      it "renders a JSON response with the new school" do
        post schools_url,
             params: { name: "high school", address: "some address" }, headers: authorization_header, as: :json

        expect(JSON.parse(response.body)).to include("name" => "high school", "address" => "some address")
      end
    end

    context "with invalid parameters" do
      it "does not create a new School" do
        expect {
          post schools_url,
               params: { name:"", address:"" }, headers: authorization_header, as: :json
        }.to change(School, :count).by(0)
      end

      it "renders a JSON response with errors for the new school" do
        post schools_url,
             params: { name:"", address:"" }, headers: authorization_header, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({"address" => ["can't be blank"],
                                                 "name" => ["can't be blank"]})
      end

      it "return name blank error" do
        post schools_url,
             params: { name:"", address:"other address" }, headers: authorization_header, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({"name" => ["can't be blank"]})
      end

      it "return address blank error" do
        post schools_url,
             params: { name:"elementary school", address:"" }, headers: authorization_header, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({"address" => ["can't be blank"]})
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates the requested school" do
        patch school_url(school),
              params: { name: "middle school" }, headers: authorization_header, as: :json
        school.reload
        expect(JSON.parse(response.body)["name"]).to eq "middle school"
      end

      it "renders a JSON response with the school" do
        patch school_url(school),
              params: { sname: "middle school", address: "new addres" }, headers: authorization_header, as: :json
        expect(response).to have_http_status(:ok)
        school.reload
        expect(JSON.parse(response.body)).to eq JSON.parse(school.to_json)
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the new school" do
        patch school_url(school),
              params: { name:"", address:"" }, headers: authorization_header, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({"address" => ["can't be blank"],
                                                 "name" => ["can't be blank"]})
      end

      it "return name blank error" do
        patch school_url(school),
              params: { name:"", address:"other address" }, headers: authorization_header, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({"name" => ["can't be blank"]})
      end

      it "return address blank error" do
        patch school_url(school),
              params: { name:"elementary school", address:"" }, headers: authorization_header, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({"address" => ["can't be blank"]})
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested school" do
      expect {
        delete school_url(school), headers: authorization_header, as: :json
      }.to change(School, :count).by(-1)
    end
  end

  def authorization_header
    { 'Authorization': "Bearer #{@token}" }
  end
end
