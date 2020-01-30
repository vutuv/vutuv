defmodule VutuvWeb.Api.Authorize do
  @moduledoc """
  Functions to help with authorization.
  """

  import Plug.Conn
  import Phoenix.Controller

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
      error(conn, :forbidden, 403)
    end
  end

  def auth_action_slug(conn, _), do: error(conn, :unauthorized, 401)

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

  def guest_check(%Plug.Conn{assigns: %{current_user: _current_user}} = conn, _opts) do
    conn
    |> put_status(:unauthorized)
    |> put_view(VutuvWeb.Api.AuthView)
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
    conn
    |> put_status(status)
    |> put_view(VutuvWeb.Api.AuthView)
    |> render("#{code}.json", [])
    |> halt()
  end
end
