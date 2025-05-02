RailsAdmin.config do |config|
  config.asset_source = :importmap

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/railsadminteam/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)


  config.authorize_with do
    redirect_to main_app.root_path, alert: "Access denied." unless current_user&.admin?
  end
  
  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    # edit
    delete
    show_in_app
    

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
  config.model 'User' do
    list do
      field :email
      field :first_name
      field :last_name
      field :avatar do
        pretty_value do
          if bindings[:object].avatar.attached?
            bindings[:view].tag(:img, {
              src: Rails.application.routes.url_helpers.rails_blob_path(bindings[:object].avatar, only_path: true),
              style: 'height: 40px; border-radius: 50%;'
            })
          else
            'No Avatar'
          end
        end
      end
      field :approved do
        formatted_value do
          case value
          when true
            'Approved'
          when false
            'Denied'
          else
            'Pending'
          end
        end
      end
      field :admin
      field :bio
      field :view_link, :string do
        label 'View'
        pretty_value do
          bindings[:view].link_to('👁️', bindings[:view].rails_admin.show_path('user', bindings[:object].id))
        end
      end
    end

    show do
      field :uuid
      field :first_name
      field :last_name
      field :email
      field :role
      field :location
      field :public_profile
      field :approved
      field :created_at
      field :updated_at
      field :avatar
      field :university_id, :string do
        formatted_value do
          if bindings[:object].university_id.attached?
            begin
              url = Rails.application.routes.url_helpers.rails_blob_url(
                bindings[:object].university_id,
                host: ENV.fetch('APP_HOST', 'http://localhost:3000')
              )
              html = <<~HTML
                <div>
                  <strong>University ID Preview:</strong><br>
                  <a href='#{url}' target='_blank'>
                    <img src='#{url}' style='max-height: 200px; border: 1px solid #ccc; margin-top: 10px;' />
                  </a>
                </div>
              HTML
              html.html_safe
            rescue => e
              "Error displaying image: #{e.message}"
            end
          else
            '❌ university_id not attached for this user.'
          end
        end
      end
      field :banner
      field :admin_note

      field :admin_approval_form, :string do
        formatted_value do
          form_html = <<~HTML
            <form action="#{bindings[:view].main_app.approve_user_path(id: bindings[:object].id)}" method="post" style="margin-bottom: 20px;">
              #{'<input type="hidden" name="_method" value="patch">'.html_safe}
              #{bindings[:view].hidden_field_tag(:authenticity_token, bindings[:view].form_authenticity_token)}
              <label for="admin_message_approve"><strong>Approve Message:</strong></label><br>
              <textarea name="admin_message" id="admin_message_approve" rows="4" style="width: 100%; margin-top: 5px;" placeholder="Optional message when approving..."></textarea><br>
              <button type="submit" class="btn btn-success" style="margin-top: 10px;">Approve & Send Message</button>
            </form>
            <form action="#{bindings[:view].main_app.deny_user_path(id: bindings[:object].id)}" method="post" style="margin-top: 10px;">
              <input type="hidden" name="_method" value="patch">
              #{bindings[:view].hidden_field_tag(:authenticity_token, bindings[:view].form_authenticity_token)}
              <label for="admin_message_deny"><strong>Deny Message:</strong></label><br>
              <textarea name="admin_message" id="admin_message_deny" rows="4" style="width: 100%; margin-top: 5px;" placeholder="Optional message when denying..."></textarea><br>
              <button type="submit" class="btn btn-danger" style="margin-top: 10px;">Deny & Send Message</button>
            </form>
          HTML
          form_html.html_safe
        end
      end
    end

    edit do
      field :first_name
      field :last_name
      field :email
      field :role
      field :location
      field :public_profile
      field :approved
      field :avatar
      field :university_id
      field :banner
      field :admin_note
    end
  end
end
