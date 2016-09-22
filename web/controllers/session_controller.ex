defmodule Vutuv.SessionController do
  use Vutuv.Web, :controller
  import Vutuv.UserHelpers

  @api_url ~s(https://graph.facebook.com/v2.3/)

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

  def facebook_auth(conn, %{"code"=> code}) do #Recieves the redirect from facebook
    HTTPoison.start #Start HTTP library

    code
    |> get_token #Get token from API call
    |> get_id #Get ID from API call
    |> get_fields #Get user fields from API call
    |> Vutuv.Auth.login_by_facebook #Try to log the user in with the info from facebook
    |> handle_facebook_login_attempt(conn) #Handle the result of the login attempt
  end

  defp handle_facebook_login_attempt({:ok, user}, conn) do #If user is found, log them in
    Vutuv.Auth.login(conn, user) #Log the user in
    |> put_flash(:info, gettext("Welcome back"))
    |> redirect(to: user_path(conn, :show, user))
  end

  defp handle_facebook_login_attempt({:error, :not_found, fields}, conn) do #Else, create the user
    Map.drop(fields,["id", "email"])
    |> Vutuv.Registration.register_user([{:oauth_providers, %Vutuv.OAuthProvider{provider: "facebook", provider_id: fields["id"]}}])
    |> case do
      {:ok, user} ->
        conn
        |> Vutuv.Auth.login(user) #Log the newly created user in
        |> put_flash(:info, "User #{full_name(user)} created successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "There was an error when trying to log you in via facebook.")
        |> render("new.html")
    end
  end

  defp get_token(code) do #Uses the code recieved from the facebook login to get an access token
    redirect_url = Application.fetch_env!(:vutuv, Vutuv.Endpoint)[:redirect_url] #Get URL from config                    
    api_call("oauth/access_token", [{"client_id","615815025247201"}, {"redirect_uri", "#{redirect_url}/sessions/facebook/auth"},  #Build the request string
                                    {"client_secret","839a7f0b468aaaf0256495c40041ecf1"}, {"code", "#{code}"}])
    |> HTTPoison.get! #Make the request
    |> decode_body #Decode and return the reply body
  end

  defp get_id(%{"access_token" => token}) do #Uses the token to get the user's facebook id
    api_call("me", [{"access_token", token}]) #Build the request string
    |> HTTPoison.get!  #Make the request
    |> decode_body #Decode and return the reply body
    |> Map.put("access_token", token) #Add the access token to the reply
  end

  defp get_fields(%{"id"=> id, "access_token" => token}) do #Uses the access token and id to get the user's facebook info
    api_call(id, [{"fields", "email,first_name,last_name"}, {"access_token", token}]) #Build the request string
    |> HTTPoison.get! #Make the request
    |> decode_body #Decode and return the reply body
  end

  defp decode_body(%HTTPoison.Response{body: body}), do: Poison.decode! body #Turns the reply body into a map that elixir can work with

  defp api_call(path, opts) do #Constructs an API request string from a path and options
    "#{@api_url}#{path}?#{
      for({k, v} <- opts) do
        "#{k}=#{v}"
      end
      |> Enum.join("&")}"
  end

  def facebook_return(conn, _params) do
    conn
    |>redirect(to: session_path(conn, :new))
  end
end
