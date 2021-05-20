require 'rails_helper'

RSpec.describe "/orders", type: :request do
  let!(:user) { create :user, email: "test@user.com", password: "123456", age: 30 }
  let!(:school) { create :school, address:"street demo", name: "high school" }
  let!(:recipient) { create :recipient, user_id: user.id, school_id: school.id, address: "some street" }
  let!(:other_school) { create :school, address:"street demo", name: "other school" }
  let!(:other_recipient) { create :recipient, user_id: user.id, school_id: other_school.id, address: "other street" }
  let!(:order) { create :order, status: "ORDER_RECEIVED", gift_type: "T_SHIRT", recipient_ids: recipient.id }
  let!(:other_order) { create :order, status: "ORDER_RECEIVED", gift_type: "T_SHIRT", recipient_ids: other_recipient.id }

  before do
    post login_url params: {email: "test@user.com", password: "123456"}
    @token = JSON.parse(response.body)["token"]
  end

  describe "GET /index" do
    it "renders a successful response" do
      get orders_url, headers: authorization_header, as: :json
      expect(response).to be_successful
    end

    it "filter by school" do
      get orders_url, headers: authorization_header, params: {school_id: other_school.id, format: :json}
      expect(response.body).to eq [other_order].to_json
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      get order_url(order), headers: authorization_header, as: :json
      expect(response).to be_successful
    end

    it "get correct order" do
      get order_url(order), headers: authorization_header, as: :json
      expect(response.body).to eq order.to_json
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Order" do
        expect {
          post orders_url,
               params: { status: "ORDER_PROCESSING", gift_type: "HOODIE", recipient_ids: [recipient.id] },
               headers: authorization_header, as: :json
        }.to change(Order, :count).by(1)
      end

      it "renders a JSON response with the new order" do
        post orders_url,
             params: { status: "ORDER_PROCESSING", gift_type: "HOODIE", recipient_ids: [recipient.id] },
             headers: authorization_header, as: :json
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include("status" => "ORDER_PROCESSING", "gift_type" => "HOODIE")
      end
    end

    context "with invalid parameters" do
      it "does not create a new Order" do
        expect {
          post orders_url,
               params: { },  headers: authorization_header, as: :json
        }.to change(Order, :count).by(0)
      end

      it "renders a JSON response with errors for the new order" do
        post orders_url,
             params: { },  headers: authorization_header, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq( "gift_type" => ["is not included in the list"],
                                                 "recipient_ids" => ["is too short (minimum is 1 character)"],
                                                 "status" => ["is not included in the list"],
                                                 )
      end

      it "return gift_type error" do
        post orders_url,
             params: { status: "ORDER_PROCESSING", gift_type: "invalid gift", recipient_ids: [recipient.id] },
             headers: authorization_header, as: :json
        expect(JSON.parse(response.body)).to eq "gift_type" => ["is not included in the list"]
      end

      it "return recipient_ids error" do
        post orders_url,
             params: { status: "ORDER_PROCESSING", gift_type: "MUG", recipient_ids: [] },
             headers: authorization_header, as: :json
        expect(JSON.parse(response.body)).to eq "recipient_ids" => ["is too short (minimum is 1 character)"]
      end

      it "return status error" do
        post orders_url,
             params: { status: "invalid status", gift_type: "MUG", recipient_ids: [recipient.id] },
             headers: authorization_header, as: :json
        expect(JSON.parse(response.body)).to eq "status" => ["is not included in the list"]
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates the requested order" do
        patch order_url(order),
              params: { status: "ORDER_CANCELLED"}, headers: authorization_header, as: :json
        order.reload
        expect( order.status).to eq("ORDER_CANCELLED")
      end

      it "renders a JSON response with the order" do
        patch order_url(order),
              params: { status: "ORDER_CANCELLED"}, headers: authorization_header, as: :json
        expect(response).to have_http_status(:ok)
        order.reload
        expect(JSON.parse(response.body)).to include(JSON.parse(order.to_json))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the order" do
        patch order_url(order),
              params: { status: "bad_status", gift_type: "invalid gift", recipient_ids: []},  headers: authorization_header, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq( "gift_type" => ["is not included in the list"],
                                                 "recipient_ids" => ["is too short (minimum is 1 character)"],
                                                 "status" => ["is not included in the list"],
                                                 )
      end

      it "return gift_type error" do
        patch order_url(order),
             params: { status: "ORDER_PROCESSING", gift_type: "invalid gift", recipient_ids: [recipient.id] },
             headers: authorization_header, as: :json
        expect(JSON.parse(response.body)).to eq "gift_type" => ["is not included in the list"]
      end

      it "return recipient_ids error" do
        patch order_url(order),
             params: { status: "ORDER_PROCESSING", gift_type: "MUG", recipient_ids: [] },
             headers: authorization_header, as: :json
        expect(JSON.parse(response.body)).to eq "recipient_ids" => ["is too short (minimum is 1 character)"]
      end

      it "return status error" do
        patch order_url(order),
             params: { status: "invalid status", gift_type: "MUG", recipient_ids: [recipient.id] },
             headers: authorization_header, as: :json
        expect(JSON.parse(response.body)).to eq "status" => ["is not included in the list"]
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested order" do
      expect {
        delete order_url(order), headers: authorization_header, as: :json
      }.to change(Order, :count).by(-1)
    end
  end

  describe "POST /ship" do
    it "change status to ORDERED_CANCELLED" do
      post "#{orders_url}/#{order.id}/Ship",
          headers: authorization_header, as: :json
      order.reload
      expect( order.status).to eq("ORDER_SHIPPED")
    end
  end

  describe "POST /cancel" do
    it "change status to ORDER_CANCELLED" do
      post "#{orders_url}/#{order.id}/cancel",
           headers: authorization_header, as: :json
      order.reload
      expect( order.status).to eq("ORDER_CANCELLED")
    end
  end

  def authorization_header
    { 'Authorization': "Bearer #{@token}" }
  end
end
