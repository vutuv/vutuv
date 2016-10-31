defmodule Vutuv.Plug.ManageCookies do
  use Plug.Builder # This allows us to plug inside a plug
  import Plug.Conn

  plug Plug.CSRFProtection

  def init(opts) do
    opts
  end

  # This plug disables crsf protection unless logged in. When logged in,
  # cookies are stored and CSRF protection is enabled. When not logged
  # in, no cookies are stored and users can still submit forms without
  # CSRF errors.

  def call(conn, opts) do
    if(conn.assigns[:current_user] || get_session(conn, "phoenix_flash")) do
      super(conn, opts) # Calls CSRFProtection
    else
       configure_session(conn, drop: true) # Drop the session, preventing cookies
    end
  end
end