class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_message, only: [:show, :reply]

  def index
    @received_messages = current_user.messages_received.order(created_at: :desc)
    @sent_messages = current_user.messages_sent.order(created_at: :desc)
    @notifications = current_user.notifications.where(read: false).order(created_at: :desc).limit(5)
  end

  def new
    @message = Message.new
    @users = User.where.not(id: current_user.id)
  end

  def create
    @message = current_user.messages_sent.build(message_params)
    if @message.save
      Notification.create!(
        recipient: @message.recipient,
        actor: current_user,
        action: 'sent you a message',
        notifiable: @message
      )
      if params[:from_order_page] == 'true'
        @checkout_order = CheckoutOrder.find(@message.checkout_order_id)
        @messages = Message.where(checkout_order_id: @checkout_order.id).order(created_at: :asc)
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to checkout_order_path(@checkout_order), notice: 'Message sent successfully.' }
        end
      else
        redirect_to messages_path, notice: 'Message sent successfully.'
      end
    else
      if params[:from_order_page] == 'true'
        @checkout_order = CheckoutOrder.find(@message.checkout_order_id)
        @messages = Message.where(checkout_order_id: @checkout_order.id).order(created_at: :asc)
        respond_to do |format|
          format.turbo_stream { render 'checkout_orders/show', status: :unprocessable_entity }
          format.html { render 'checkout_orders/show', status: :unprocessable_entity }
        end
      else
        @users = User.where.not(id: current_user.id)
        render :new, status: :unprocessable_entity
      end
    end
  end

  def show
    @reply = Message.new
  end

  def reply
    @reply = current_user.messages_sent.build(
      recipient: @message.sender,
      body: params[:body]
    )
    if @reply.save
      Notification.create!(
        recipient: @message.sender,
        actor: current_user,
        action: 'replied to your message',
        notifiable: @reply
      )
      redirect_to message_path(@message), notice: 'Reply sent.'
    else
      render :show
    end
  end

  def clear_inbox
    current_user.messages_received.destroy_all
    redirect_to messages_path, notice: "Inbox messages cleared."
  end

  def clear_sent
    current_user.messages_sent.destroy_all
    redirect_to messages_path, notice: "Sent messages cleared."
  end

  def destroy
    message = current_user.messages_sent.find_by(id: params[:id]) || current_user.messages_received.find_by(id: params[:id])
    if message
      message.destroy
      redirect_to messages_path, notice: 'Message deleted.'
    else
      redirect_to messages_path, alert: 'Message not found or not authorized.'
    end
  end

  private

  def set_message
    @message = Message.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:recipient_id, :body, :checkout_order_id)
  end
end
