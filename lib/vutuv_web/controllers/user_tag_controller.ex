defmodule VutuvWeb.UserTagController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Vutuv.{Tags, Tags.UserTag}

  @dialyzer {:nowarn_function, new: 3}

  def action(conn, _), do: auth_action_slug(conn, __MODULE__)

  def new(conn, _params, _current_user) do
    changeset = Tags.change_user_tag(%UserTag{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user_tag" => user_tag_params}, current_user) do
    case Tags.create_user_tag(current_user, user_tag_params) do
      {:ok, _user_tag} ->
        conn
        |> put_flash(:info, gettext("User tag created successfully."))
        |> redirect(to: Routes.user_path(conn, :show, current_user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    user_tag = Tags.get_user_tag!(current_user, id)
    {:ok, _user_tag} = Tags.delete_user_tag(user_tag)

    conn
    |> put_flash(:info, gettext("User tag deleted successfully."))
    |> redirect(to: Routes.user_path(conn, :show, current_user))
  end
end
