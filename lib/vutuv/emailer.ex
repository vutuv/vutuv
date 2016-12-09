defmodule Vutuv.Emailer do
  import Bamboo.Email
  require Vutuv.Gettext
  use Bamboo.Phoenix, view: Vutuv.EmailView

  def login_email(link, email, %Vutuv.User{validated?: false} = user) do
    gen_email(link, email, user, "registration_email_#{get_locale(user.locale)}", Vutuv.Gettext.gettext("Confirm your vutuv account"))
  end

  def login_email(link, email, user) do
    gen_email(link, email, user, "login_email_#{get_locale(user.locale)}", Vutuv.Gettext.gettext("Login to vutuv"))
  end

  def email_creation_email(link, email, user) do

    gen_email(link, email, user,"email_creation_email_#{get_locale(user.locale)}", Vutuv.Gettext.gettext("Confirm your email"))
  end

  def user_deletion_email(link, email, user) do
    gen_email(link, email, user,"user_deletion_email_#{get_locale(user.locale)}", Vutuv.Gettext.gettext("Confirm your account deletion"))
  end

  defp gen_email(link, email, user, template, email_subject) do
    url = Application.get_env(:vutuv, Vutuv.Endpoint)[:public_url]
    new_email
    |> put_text_layout({Vutuv.EmailView, "#{template}.text"})
    |> assign(:link, link)
    |> assign(:url, url)
    |> assign(:user, user)
    |> to("#{Vutuv.UserHelpers.name_for_email_to_field(user)} <#{email}>")
    |> from("vutuv <info@vutuv.de>")
    |> subject(email_subject)
    |> render("#{template}.text")
  end

  defp get_locale(nil), do: "en"

  defp get_locale(locale) do
    if(Vutuv.Plug.Locale.locale_supported?(locale)) do
      locale
    else
      "en"
    end
  end
end
