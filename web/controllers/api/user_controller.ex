defmodule Vutuv.Api.UserController do
use Vutuv.Web, :controller

  plug :resolve_slug when action in [:show]

  alias Vutuv.User
  alias Vutuv.Slug

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.json", users: users)
  end

  # def create(conn, %{"user" => user_params}) do
  #   changeset = User.changeset(%User{}, user_params)

  #   case Repo.insert(changeset) do
  #     {:ok, user} ->
  #       conn
  #       |> put_status(:created)
  #       |> put_resp_header("location", user_path(conn, :show, user))
  #       |> render("show.json", user: user)
  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> render(Vutuv.ChangesetView, "error.json", changeset: changeset)
  #   end
  # end

  def show(conn, _params) do
    user = Repo.get!(User, conn.assigns[:user_id])
    |> Repo.preload([:emails, :work_experiences,
                    :addresses, :phone_numbers,
                    :social_media_accounts, :urls,
                    user_skills: :skill])
    render(conn, "show.json", user: user)
  end

  # def update(conn, %{"id" => id, "user" => user_params}) do
  #   user = Repo.get!(User, id)
  #   changeset = User.changeset(user, user_params)

  #   case Repo.update(changeset) do
  #     {:ok, user} ->
  #       render(conn, "show.json", user: user)
  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> render(Vutuv.ChangesetView, "error.json", changeset: changeset)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   user = Repo.get!(User, id)

  #   # Here we use delete! (with a bang) because we expect
  #   # it to always work (and if it does not, it will raise).
  #   Repo.delete!(user)

  #   send_resp(conn, :no_content, "")
  # end

  defp resolve_slug(conn, _opts) do
    case conn.params do
      %{"slug" => slug} ->
        case Repo.one(from s in Slug, where: s.value == ^slug) do
          nil  -> invalid_slug(conn)
          %{disabled: false, user_id: user_id} ->
            user = Repo.get!(Vutuv.User, user_id)
            if(user.active_slug != slug) do
              redirect(conn, to: api_user_path(conn, :show, user))
            else
              assign(conn, :user_id, user_id)
            end
          _ -> invalid_slug(conn)
        end
      _ -> invalid_slug(conn)
    end
  end

  defp invalid_slug(conn) do
    conn
    |> put_status(:not_found)
    |> render(Vutuv.ErrorView, "error.json")
    |> halt
  end
end
