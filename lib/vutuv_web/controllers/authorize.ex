defmodule VutuvWeb.Authorize do
  @moduledoc """
  Functions to help with authorization.

  See the [Authorization wiki page](https://github.com/riverrun/phauxth/wiki/Authorization)
  for more information and examples about authorization.
  """

  import Plug.Conn
  import Phoenix.Controller

  alias VutuvWeb.Router.Helpers, as: Routes

  @doc """
  Overrides the controller module's action function with an id check - to
  make sure that the current user can access the resource.
  """
  def auth_action_id(
        %Plug.Conn{
          params: %{"user_id" => user_id} = params,
          assigns: %{current_user: %{id: id} = current_user}
        } = conn,
        module
      ) do
    if user_id == to_string(id) do
      apply(module, action_name(conn), [conn, params, current_user])
    else
      conn
      |> put_flash(:error, "You are not authorized to view this page")
      |> redirect(to: Routes.user_path(conn, :show, current_user))
      |> halt()
    end
  end

  def auth_action_id(conn, _), do: need_login(conn)

  @doc """
  Plug to only allow authenticated users to access the resource.

  See the user controller for an example.
  """
  def user_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    need_login(conn)
  end

  def user_check(conn, _opts), do: conn

  @doc """
  Plug to only allow unauthenticated users to access the resource.

  See the session controller for an example.
  """
  def guest_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts), do: conn

  def guest_check(%Plug.Conn{assigns: %{current_user: user}} = conn, _opts) do
    conn
    |> put_flash(:error, "You need to log out to view this page")
    |> redirect(to: Routes.user_path(conn, :show, user))
    |> halt()
  end

  @doc """
  Plug to only allow authenticated users with the correct id to access the resource.

  See the user controller for an example.
  """
  def id_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    need_login(conn)
  end

  def id_check(
        %Plug.Conn{params: %{"id" => id}, assigns: %{current_user: current_user}} = conn,
        _opts
      ) do
    if id == to_string(current_user.id) do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to view this page")
      |> redirect(to: Routes.user_path(conn, :show, current_user))
      |> halt()
    end
  end

  defp need_login(conn) do
    conn
    |> put_session(:request_path, current_path(conn))
    |> put_flash(:error, "You need to log in to view this page")
    |> redirect(to: Routes.session_path(conn, :new))
    |> halt()
  end
end
