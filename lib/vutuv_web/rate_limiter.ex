defmodule VutuvWeb.RateLimiter do
  @moduledoc """
  Plug to handle rate limiting.
  """

  @behaviour Plug

  import Phoenix.Controller
  import Plug.Conn
  import VutuvWeb.Gettext

  alias VutuvWeb.Router.Helpers, as: Routes

  @impl Plug
  def init(opts) do
    Keyword.get(opts, :type, :authenticate)
  end

  @impl Plug
  def call(conn, :authenticate) do
    user_name = user_name(conn, "session")
    ip_name = ip_name(conn)

    with {:allow, _} <- Hammer.check_rate(user_name, 60 * 1000, 5),
         {:allow, _} <- Hammer.check_rate(ip_name, 300 * 1000, 50) do
      assign(conn, :rate_limit_name, {user_name, ip_name})
    else
      _ -> render_error(conn)
    end
  end

  def call(conn, params_id) do
    user_name = user_name(conn, to_string(params_id))

    case Hammer.check_rate(user_name, 90 * 1000, 2) do
      {:allow, _} -> assign(conn, :rate_limit_name, user_name)
      _ -> render_error(conn)
    end
  end

  @doc """
  Resets the count of certain buckets.

  This is used after a successful login / verification.
  """
  @spec reset_count(Plug.Conn.t()) :: :ok
  def reset_count(%Plug.Conn{assigns: %{rate_limit_name: {user_name, ip_name}}}) do
    Hammer.delete_buckets(user_name)
    Hammer.delete_buckets(ip_name)
    :ok
  end

  def reset_count(%Plug.Conn{assigns: %{rate_limit_name: name}}) do
    Hammer.delete_buckets(name)
    :ok
  end

  def reset_count(_), do: :ok

  defp ip_name(conn) do
    ip = conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
    "#{ip}:#{conn.request_path}"
  end

  defp user_name(conn, params_id) do
    %{^params_id => %{"email" => email}} = conn.params
    "#{email}:#{conn.request_path}"
  end

  defp render_error(%Plug.Conn{private: %{:phoenix_format => "json"}} = conn) do
    conn
    |> put_status(:too_many_requests)
    |> put_view(VutuvWeb.AuthView)
    |> render("#{429}.json", [])
    |> halt()
  end

  defp render_error(conn) do
    conn
    |> put_flash(:error, gettext("Too many requests. Please try again later."))
    |> redirect(to: Routes.user_path(conn, :new))
    |> halt()
  end
end
