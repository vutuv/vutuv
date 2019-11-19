defmodule VutuvWeb.Authorize do
  @moduledoc """
  Functions to help with authorization.

  See the [Authorization wiki page](https://github.com/riverrun/phauxth/wiki/Authorization)
  for more information and examples about authorization.
  """

  import Plug.Conn
  import Phoenix.Controller
  import VutuvWeb.Gettext

  alias VutuvWeb.Router.Helpers, as: Routes

  @doc """
  Overrides the controller module's action function with a current_user check.
  """
  def auth_action_slug(
        %Plug.Conn{params: params, assigns: %{current_user: %{slug: slug} = current_user}} = conn,
        module
      ) do
    if slug in [params["user_slug"], params["slug"]] do
      apply(module, action_name(conn), [conn, params, current_user])
    else
      unauthorized(conn, current_user)
    end
  end

  def auth_action_slug(conn, _), do: need_login(conn)

  @doc """
  Similar to auth_action_slug/2, but does not check actions that are in the
  `except` list.
  """
  def auth_action_slug(conn, module, except) do
    action = action_name(conn)

    if action in except do
      apply(module, action, [conn, conn.params, conn.assigns.current_user])
    else
      auth_action_slug(conn, module)
    end
  end

  @doc """
  Plug to only allow unauthenticated users to access the resource.

  See the session controller for an example.
  """
  def guest_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts), do: conn

  def guest_check(%Plug.Conn{assigns: %{current_user: user}} = conn, _opts) do
    conn
    |> put_flash(:error, gettext("You need to log out to view this page"))
    |> redirect(to: Routes.user_path(conn, :show, user))
    |> halt()
  end

  @doc """
  Redirects user when user is not authorized to access the resource.
  """
  def unauthorized(conn, current_user) do
    conn
    |> put_flash(:error, gettext("You are not authorized to view this page"))
    |> redirect(to: Routes.user_path(conn, :show, current_user))
    |> halt()
  end

  @doc """
  Redirects user when user is not authenticated - current_user is nil.
  """
  def need_login(conn) do
    conn
    |> put_session(:request_path, current_path(conn))
    |> put_flash(:error, gettext("You need to log in to view this page"))
    |> redirect(to: Routes.session_path(conn, :new))
    |> halt()
  end
end
