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
    edit
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
      field :admin
      field :bio
    end
  end
end
