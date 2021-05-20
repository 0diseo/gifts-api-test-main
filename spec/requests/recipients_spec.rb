require 'rails_helper'

RSpec.describe "/recipients", type: :request do
  let!(:user) { create :user, email: "test@user.com", password: "123456", age: 30 }
  let!(:school) { create :school, address:"street demo", name: "high school" }
  let!(:recipient) { create :recipient, user_id: user.id, school_id: school.id, address: "some street" }
  let!(:other_school) { create :school, address:"street demo", name: "other school" }
  let!(:other_recipient) { create :recipient, user_id: user.id, school_id: other_school.id, address: "other street" }

  before do
    post login_url params: {email: "test@user.com", password: "123456"}
    @token = JSON.parse(response.body)["token"]
  end

  describe "GET /index" do
    it "renders a successful response" do
      get recipients_url, headers: authorization_header, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      get recipient_url(recipient), headers: authorization_header, as: :json
      expect(response.body).to eq recipient.to_json
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Recipient" do
        expect {
          post recipients_url,
               params: { user_id: user.id, school_id: school.id, address: "some street"  }, headers: authorization_header, as: :json
        }.to change(Recipient, :count).by(1)
      end

      it "renders a JSON response with the new recipient" do
        post recipients_url,
             params: { user_id: user.id, school_id: school.id, address: "some street"  }, headers: authorization_header, as: :json
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include("user_id" => user.id, "school_id" => school.id,"address" => "some street")
      end
    end

    context "with invalid parameters" do
      it "does not create a new Recipient" do
        expect {
          post recipients_url,
               params: { user_id: "", address:"" }, as: :json
        }.to change(Recipient, :count).by(0)
      end

      it "renders a JSON response with errors for the new recipient" do
        post recipients_url,
             params: { user_id: "", address:"" }, headers: authorization_header, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({"address" => ["can't be blank"],
                                                 "user" => ["must exist"]})
      end

      it "return user must exist error" do
        post recipients_url,
             params: { user_id: "", address:"somewhere" }, headers: authorization_header, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ "user" => ["must exist"] })
      end

      it "return address can't be blank error" do
        post recipients_url,
             params: { user_id: user.id, address:"" }, headers: authorization_header, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({"address" => ["can't be blank"]})
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested recipient" do
        patch recipient_url(recipient),
              params: { school_id: other_school.id }, headers: authorization_header, as: :json
        recipient.reload
        expect(JSON.parse(response.body)["school_id"]).to eq other_school.id
      end

      it "renders a JSON response with the recipient" do
        patch recipient_url(recipient),
              params: { school_id: other_school.id }, headers: authorization_header, as: :json
        recipient.reload
        expect(JSON.parse(response.body)).to eq JSON.parse(recipient.to_json)
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the recipient" do
        patch recipient_url(recipient),
              params: { user_id: "", address:"" }, headers: authorization_header, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({"address" => ["can't be blank"],
                                                 "user" => ["must exist"]})
      end

      it "return user must exist error" do
        patch recipient_url(recipient),
             params: { user_id: "", address:"somewhere" }, headers: authorization_header, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ "user" => ["must exist"] })
      end

      it "return address can't be blank error" do
        patch recipient_url(recipient),
             params: { user_id: user.id, address:"" }, headers: authorization_header, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({"address" => ["can't be blank"]})
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested recipient" do
      expect {
        delete recipient_url(recipient), headers: authorization_header, as: :json
      }.to change(Recipient, :count).by(-1)
    end
  end

  def authorization_header
    { 'Authorization': "Bearer #{@token}" }
  end
end
