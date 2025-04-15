# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :set_devise_mapping

  def new
    build_resource
    respond_with resource
  end

  def create
    build_resource(sign_up_params)
  
    # ✅ Manually attach the uploaded file before save
    if params[:user][:university_id].present?
      resource.university_id.attach(params[:user][:university_id])
    end
  
    # ✅ Add these two lines:
    resource.uuid = SecureRandom.uuid unless resource.uuid.present?
    resource.approved = false
  
    # 🌟 Handle missing fields
    missing = []
    missing << "first name" if resource.first_name.blank?
    missing << "last name" if resource.last_name.blank?
    missing << "password" if resource.password.blank?
    missing << "university ID" unless resource.university_id.attached?
  
    if missing.any?
      flash.now[:alert] = "Please provide: #{missing.to_sentence}."
      flash.now[:notice] = "Please re-upload your University ID and re-enter password if needed." if missing.include?("password") || missing.include?("university ID")
      render :new, status: :unprocessable_entity and return
    end
  
    if resource.save
      sign_up(resource_name, resource)
      redirect_to successfully_created_account_path
    else
      Rails.logger.debug(resource.errors.full_messages)
      clean_up_passwords(resource)
      set_minimum_password_length
      render :new, status: :unprocessable_entity
    end
  end
  
  

  def success
    render 'users/registrations/successfully_created_account'
  end

  private

  def sign_up_params
    params.require(:user).permit(
      :email,
      :first_name,
      :last_name,
      :password,
      :password_confirmation,
      :university_id
    )
  end
  

  def set_devise_mapping
    request.env["devise.mapping"] = Devise.mappings[:user]
  end
end
