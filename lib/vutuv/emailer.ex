defmodule Vutuv.Emailer do
  import Bamboo.Email
  use Bamboo.Phoenix, view: Vutuv.EmailView

  def login_email(link, email) do
    new_email
    |> put_html_layout({Vutuv.EmailView, "email.html"})
    |> assign(:link, link)
    |> to(email)
    |> from("mailer@localhost")
    |> subject("Login")
    |> render("email.html")
  end
end
