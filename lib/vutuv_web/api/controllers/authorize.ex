defmodule VutuvWeb.Api.Authorize do
  @moduledoc """
  Functions to help with authorization.
  """

  import Plug.Conn
  import Phoenix.Controller

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
      error(conn, :forbidden, 403)
    end
  end

  def auth_action_id(conn, _), do: error(conn, :unauthorized, 401)

  @doc """
  Plug to only allow unauthenticated users to access the resource.

  See the session controller for an example.
  """
  def guest_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts), do: conn

  def guest_check(%Plug.Conn{assigns: %{current_user: _current_user}} = conn, _opts) do
    conn
    |> put_status(:unauthorized)
    |> put_view(VutuvWeb.AuthView)
    |> render("logged_in.json", [])
    |> halt()
  end

  @doc """
  Plug to only allow authenticated users with the correct id to access the resource.

  See the user controller for an example.
  """
  def id_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    error(conn, :unauthorized, 401)
  end

  def id_check(
        %Plug.Conn{params: %{"id" => id}, assigns: %{current_user: current_user}} = conn,
        _opts
      ) do
    if id == to_string(current_user.id) do
      conn
    else
      error(conn, :forbidden, 403)
    end
  end

  def error(conn, status, code) do
    put_status(conn, status)
    |> put_view(VutuvWeb.AuthView)
    |> render("#{code}.json", [])
    |> halt()
  end
end
