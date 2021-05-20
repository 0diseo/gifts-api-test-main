class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :update, :destroy, :cancel, :Ship]

  # GET /orders
  def index
    @orders = params[:school_id] ?
                Order.left_outer_joins(:recipients).where(recipients:{school_id: params[:school_id]}) :
                Order.all

    render json: @orders
  end

  # GET /orders/1
  def show
    render json: @order
  end

  # POST /orders
  def create
    @order = Order.new(order_params)
    if @order.save
      render json: @order, status: :created, location: @order
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /orders/1
  def update
    if @order.update(order_params)
      render json: @order
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  # DELETE /orders/1
  def destroy
    @order.destroy
  end

  # PUT /orders/1/cancel
  def cancel
    if @order.update({status: "ORDER_CANCELLED"})
      render json: @order
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  # PUT /orders/1/Ship
  def Ship
    if @order.update({status: "ORDER_SHIPPED"})
      #send email here
      render json: @order
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def order_params
      params.permit(:status, :gift_type, recipient_ids: [] )
    end
end
