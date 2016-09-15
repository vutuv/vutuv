defmodule Vutuv.SessionController do
  use Vutuv.Web, :controller
  import Vutuv.UserHelpers

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email}}) do
    case Vutuv.Auth.login_by_email(conn, email, repo: Repo) do
      {:ok, link, conn} ->
        #Vutuv.Emailer.login_email(email, link)                           #Uncomment this when smtp server is prepared
        #|>Vutuv.Mailer.deliver_now                                       #this too
        conn
        |> put_flash(:info, gettext("localhost:4000/magic/")<>link)       #comment or delete this too
        |> redirect(to: page_path(conn, :index))
        #|> redirect(to: user_path(conn, :show, conn.assigns[:current_user]))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, gettext("Invalid email"))
        |> render("new.html")
    end
  end

  def show(conn, %{"magiclink"=>link}) do
    case Vutuv.MagicLinkHelpers.check_magic_link(link, "login") do
      {:ok, user} -> 
        Vutuv.Auth.login(conn,user)
        |> put_flash(:info, gettext("Welcome back"))
        |> redirect(to: user_path(conn, :show, user))
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: page_path(conn, :index))
    end
  end

  def delete(conn, _) do
    conn
    |> Vutuv.Auth.logout()
    |> redirect(to: page_path(conn, :index))
  end

  def facebook_login(conn, _params) do
    redirect_url = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:redirect_url]
    conn
    |>redirect(external: "https://www.facebook.com/dialog/oauth?client_id=615815025247201&redirect_uri=#{redirect_url}/sessions/facebook/auth")
  end

  def facebook_auth(conn, %{"code"=> code}) do
    redirect_url = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:redirect_url]
    HTTPoison.start
    %HTTPoison.Response{body: body} = HTTPoison.get!("https://graph.facebook.com/v2.3/oauth/access_token?client_id=615815025247201&redirect_uri=#{redirect_url}/sessions/facebook/auth&client_secret=839a7f0b468aaaf0256495c40041ecf1&code=#{code}")
    %{"access_token" => token} = Poison.decode! body
    %HTTPoison.Response{body: body} = HTTPoison.get!("https://graph.facebook.com/v2.2/me?access_token=#{token}")
    %{"id"=> id} = Poison.decode! body
    %HTTPoison.Response{body: body} = HTTPoison.get!("https://graph.facebook.com/v2.2/#{id}?fields=email,first_name,last_name&access_token=#{token}")
    fields = Poison.decode!(body)
    user_params =  Map.drop(fields,["id", "email"])
    IO.puts inspect fields
    case Vutuv.Auth.login_by_facebook(fields) do
      {:ok, user} ->
        Vutuv.Auth.login(conn, user)
        |> put_flash(:info, gettext("Welcome back"))
        |> redirect(to: user_path(conn, :show, user))
      {:error, :not_found}->
        case Vutuv.Registration.register_user(user_params, [{:oauth_providers, %Vutuv.OAuthProvider{provider: "facebook", provider_id: fields["id"]}}]) do
          {:ok, user} ->
            conn
            |> Vutuv.Auth.login(user)
            |> put_flash(:info, "User #{full_name(user)} created successfully.")
            |> redirect(to: user_path(conn, :show, user))
          {:error, _changeset} ->
            render(conn, "new.html")
        end
    end
    conn
    |>redirect(to: session_path(conn, :new))
  end

  def facebook_return(conn, _params) do
    conn
    |>redirect(to: session_path(conn, :new))
  end
end
