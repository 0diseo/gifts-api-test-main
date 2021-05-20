class RecipientsController < ApplicationController
  before_action :set_recipient, only: [:show, :update, :destroy]

  # GET /recipients
  def index
    @recipients = params[:school_id] ? Recipient.where(school_id: recipient_params[:school_id]) : Recipient.all

    render json: @recipients
  end

  # GET /recipients/1
  def show
    render json: @recipient
  end

  # POST /recipients
  def create
    @recipient = Recipient.new(recipient_params)

    if @recipient.save
      render json: @recipient, status: :created, location: @recipient
    else
      render json: @recipient.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /recipients/1
  def update
    if @recipient.update(recipient_params)
      render json: @recipient
    else
      render json: @recipient.errors, status: :unprocessable_entity
    end
  end

  # DELETE /recipients/1
  def destroy
    @recipient.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recipient
      @recipient = Recipient.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def recipient_params
      params.require(:recipient).permit(:user_id, :address, :school_id, :order_id, gift: [])
    end
end
