defmodule Vutuv.Emailer do
  import Bamboo.Email
  require Ecto.Query
  require Vutuv.Gettext
  use Bamboo.Phoenix, view: Vutuv.EmailView

  def login_email({link, pin}, email, %Vutuv.User{validated?: false} = user) do
    gen_email(link, pin, email, user, "registration_email_#{get_locale(user.locale)}", Vutuv.Gettext.gettext("Confirm your vutuv account"))
  end

  def login_email({link, pin}, email, user) do
    gen_email(link, pin, email, user, "login_email_#{get_locale(user.locale)}", Vutuv.Gettext.gettext("Login to vutuv"))
  end

  def fbs_login_email({link, pin}, email, %Vutuv.User{validated?: false} = user) do
    gen_email(link, pin, email, user, "fbs_registration_email_#{get_locale(user.locale)}", Vutuv.Gettext.gettext("Confirm your vutuv account"))
  end

  def fbs_login_email({link, pin}, email, user) do
    gen_email(link, pin, email, user, "fbs_login_email_#{get_locale(user.locale)}", Vutuv.Gettext.gettext("Login to vutuv"))
  end

  def email_creation_email({link, pin}, email, user) do

    gen_email(link, pin, email, user,"email_creation_email_#{get_locale(user.locale)}", Vutuv.Gettext.gettext("Confirm your email"))
  end

  def user_deletion_email({link, pin}, email, user) do
    gen_email(link, pin, email, user,"user_deletion_email_#{get_locale(user.locale)}", Vutuv.Gettext.gettext("Confirm your account deletion"))
  end

  def payment_information_email(email, user) do
    gen_email(nil, nil, email, user,"payment_information_email_#{get_locale(user.locale)}", Vutuv.Gettext.gettext("vutuv recruiter package subscription"))
  end

  def verification_notice(user) do
    email = Vutuv.Repo.one(Ecto.Query.from e in Vutuv.Email, where: e.user_id == ^user.id, limit: 1, select: e.value)
    template = "verification_confirmation_#{get_locale(user.locale)}"

    new_email
    |> put_text_layout({Vutuv.EmailView, "#{template}.text"})
    |> assign(:user, user)
    |> to("#{Vutuv.UserHelpers.name_for_email_to_field(user)} <#{email}>")
    |> from("vutuv <info@vutuv.de>")
    |> subject(Vutuv.Gettext.gettext("vutuv Account verified"))
    |> render("#{template}.text")
    |> Vutuv.Mailer.deliver_now
  end

  def birthday_reminder(user, birthday_childs, future_birthday_childs) do
    {{today_year, _month, _day}, {_, _, _}} = :calendar.local_time()

    name_list = for(birthday_child <- birthday_childs) do
      {:ok, {birthday_year, _, _}} = Ecto.Date.dump(birthday_child.birthdate)
      case birthday_year do
        1900 ->
          Vutuv.UserHelpers.full_name(birthday_child)
        _ ->
          "#{Vutuv.UserHelpers.full_name(birthday_child)} (#{today_year - birthday_year})"
      end
    end

    # Don't let the subject become to long.
    #
    full_names_with_age = Enum.join(name_list, ", ")
    truncated_subject = if String.length(full_names_with_age) > 50 do
      "#{String.slice(full_names_with_age, 0..45)} ..."
    else
      full_names_with_age
    end

    template = "birthday_reminder_#{get_locale(user.locale)}"

    email = Vutuv.Repo.one(Ecto.Query.from e in Vutuv.Email, where: e.user_id == ^user.id, limit: 1, select: e.value)

    Gettext.put_locale(Vutuv.Gettext, user.locale)

    new_email
    |> put_text_layout({Vutuv.EmailView, "#{template}.text"})
    |> assign(:user, user)
    |> assign(:birthday_childs, birthday_childs)
    |> assign(:future_birthday_childs, future_birthday_childs)
    |> to("#{Vutuv.UserHelpers.name_for_email_to_field(user)} <#{email}>")
    |> from("vutuv <info@vutuv.de>")
    |> subject("#{Vutuv.Gettext.gettext("Birthday")}: #{truncated_subject}")
    |> render("#{template}.text")
  end

  defp gen_email(link, pin, email, user, template, email_subject) do
    url = Application.get_env(:vutuv, Vutuv.Endpoint)[:public_url]
    new_email
    |> put_text_layout({Vutuv.EmailView, "#{template}.text"})
    |> assign(:link, link)
    |> assign(:pin, pin)
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
