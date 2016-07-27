defmodule Vutuv.Emailer do
  import Bamboo.Email
  use Bamboo.Phoenix, view: Vutuv.EmailView

  def login_email(email, link) do
    new_email
    |> to(email)
    |> from("mailer@localhost")
    |> subject("Login")
    |> render("email.html", link: link)
  end
end
