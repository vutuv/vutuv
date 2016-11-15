defmodule Vutuv.Emailer do
  import Bamboo.Email
  use Bamboo.Phoenix, view: Vutuv.EmailView

  def login_email(link, email) do
    gen_email(link, email, "login_email")
  end

  def email_creation_email(link, email) do
    gen_email(link, email, "email_creation_email")
  end

  defp gen_email(link, email, template) do
    url = Application.get_env(:vutuv, Vutuv.Endpoint)[:public_url]

    new_email
    |> put_html_layout({Vutuv.EmailView, "#{template}.html"})
    |> assign(:link, link)
    |> assign(:url, url)
    |> to(email)
    |> from("vutuv <info@vutuv.de>")
    |> subject("Verification email from vutuv")
    |> render("#{template}.html")
  end
end
