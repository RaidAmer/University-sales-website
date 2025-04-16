# frozen_string_literal: true
require 'pdf-reader'
require 'rtesseract'


class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :set_devise_mapping

  def new
    build_resource
    respond_with resource
  end

  def create
    build_resource(sign_up_params)

    #  Manually attach uploaded file
    if params[:user][:university_id].present?
      resource.university_id.attach(params[:user][:university_id])
    end

    #  Extract UUID from form and PDF
    typed_uuid = params[:user][:uuid_confirmation].to_s.strip
    extracted_uuid = extract_uuid_from_file(params[:user][:university_id].tempfile, params[:user][:university_id].content_type)

    # 🔒 Validate UUID match
    if typed_uuid.blank? || extracted_uuid.blank? || typed_uuid != extracted_uuid
      flash.now[:alert] = "❌ UUID mismatch. Please enter the correct UUID shown on your uploaded ID."
      render :new, status: :unprocessable_entity and return
    end

    #  Save to DB
    resource.uuid = typed_uuid
    resource.approved = false

    #  Required fields check
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
      #  Don't add :uuid_confirmation here! It's a virtual param.
    )
  end

  def set_devise_mapping
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  def extract_uuid_from_file(tempfile, content_type)
    text = if content_type == "application/pdf"
      reader = PDF::Reader.new(tempfile)
      reader.pages.map(&:text).join("\n")
    elsif content_type.start_with?("image/")
      image = RTesseract.new(tempfile.path)
      image.to_s
    else
      return nil
    end
  
    # Extract UUID-like format: U followed by 8 digits
    id_regex = /\bU\d{8}\b/
    match = text.match(id_regex)
    match ? match[0].strip : nil
  end
  
end
