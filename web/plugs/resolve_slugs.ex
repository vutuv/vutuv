defmodule Vutuv.Plug.ResolveSlug do
  import Plug.Conn
  import Ecto.Query
  import Phoenix.Controller
  alias Vutuv.Repo
  alias Vutuv.Router.Helpers

  def init([slug: slug_variable_name, model: model,  assign: assign_name, field: field]) do
    %{
      slug: slug_variable_name,
      model: model,
      field: field,
      assign: assign_name
    }
  end

  def call(%{params: params} = conn, %{slug: slug_variable_name, model: model, field: field, assign: assign_name}) do
    with  %{^slug_variable_name => slug} <- params,
          nil <- Repo.one(from m in model, where: field(m, ^field) == ^slug) do
      invalid_slug(conn)
    else
      result -> assign(conn, assign_name, result)
    end
  end

  def call(conn, _params) do
    invalid_slug(conn)
  end

  defp invalid_slug(conn) do
    conn
    |> put_status(:not_found)
    |> render(Vutuv.ErrorView, "404.html")
    |> halt
  end
end
