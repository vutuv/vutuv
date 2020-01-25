# {:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.configure(exclude: :rate_limiting)
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Vutuv.Repo, :manual)
