class PreferencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_preference

  def edit
    @customization_message = "Welcome to your customization dashboard!"
  end

  def update
    theme_param = preference_params[:theme]

    if @preference.update(theme: theme_param, show_welcome: preference_params[:show_welcome])
      flash[:notice] = "Preferences updated!"
      redirect_to profile_path
    else
      render :edit
    end
  end

  private

  def set_preference
    @preference = current_user.preference || current_user.build_preference
  end

  def preference_params
    params.require(:preference).permit(:theme, :pattern, :show_welcome)
  end
end
