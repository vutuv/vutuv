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
    url = 
      Application.get_env(:vutuv, Vutuv.Endpoint)[:url]
      |> Keyword.get(:host)

    new_email
    |> put_html_layout({Vutuv.EmailView, "#{template}.html"})
    |> assign(:link, link)
    |> assign(:url, url)
    |> to(email)
    |> from("info@vutuv.de")
    |> subject("Verification Email From Vutuv")
    |> render("#{template}.html")
  end
end
