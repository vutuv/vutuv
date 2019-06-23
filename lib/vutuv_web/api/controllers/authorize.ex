defmodule VutuvWeb.Api.Authorize do
  @moduledoc """
  Functions to help with authorization.
  """

  import Plug.Conn
  import Phoenix.Controller

  @doc """
  Overrides the controller module's action function with a slug check - to
  make sure that the current user can access the resource.
  """
  def auth_action_slug(
        %Plug.Conn{
          params: %{"user_slug" => user_slug} = params,
          assigns: %{current_user: %{slug: slug} = current_user}
        } = conn,
        module
      ) do
    if user_slug == slug do
      apply(module, action_name(conn), [conn, params, current_user])
    else
      error(conn, :forbidden, 403)
    end
  end

  def auth_action_slug(conn, _), do: error(conn, :unauthorized, 401)

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
  Plug to only allow authenticated users with the correct slug to access the resource.

  See the user controller for an example.
  """
  def slug_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    error(conn, :unauthorized, 401)
  end

  def slug_check(
        %Plug.Conn{params: %{"slug" => user_slug}, assigns: %{current_user: %{slug: slug}}} =
          conn,
        _opts
      ) do
    if user_slug == slug, do: conn, else: error(conn, :forbidden, 403)
  end

  def error(conn, status, code) do
    put_status(conn, status)
    |> put_view(VutuvWeb.AuthView)
    |> render("#{code}.json", [])
    |> halt()
  end
end
