defmodule Vutuv.Repo do
  use Ecto.Repo,
    otp_app: :vutuv,
    adapter: Ecto.Adapters.Postgres

  use Scrivener
end
