defmodule Vutuv.Plug.AuthRecruiter do
  import Plug.Conn
  import Phoenix.Controller

  alias Vutuv.RecruiterSubscription

  def init(opts) do
    opts
  end

  def call(conn, _default) do
    current_user = conn.assigns[:current_user]

    if current_user do
      if current_user.id != conn.assigns[:user_id] do
        forbidden(conn)
      else
        active_subscription = RecruiterSubscription.active_subscription(conn.assigns[:user_id])
        if active_subscription && active_subscription.paid do
          conn
        else
          forbidden(conn)
        end
      end
    else
      forbidden(conn)
    end
  end

  defp forbidden(conn) do
    conn
      |> put_status(403)
      |> render(Vutuv.ErrorView, "403.html")
      |> halt
  end
end
