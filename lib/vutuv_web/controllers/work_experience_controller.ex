defmodule VutuvWeb.WorkExperienceController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Vutuv.{Biographies, Biographies.WorkExperience, UserProfiles, UserProfiles.User}

  @dialyzer {:nowarn_function, new: 3}

  def action(conn, _) do
    if action_name(conn) in [:index, :show] do
      apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
    else
      auth_action_slug(conn, __MODULE__)
    end
  end

  def index(conn, %{"user_slug" => slug}, %User{slug: slug} = current_user) do
    work_experiences = Biographies.list_work_experiences(current_user)
    render(conn, "index.html", work_experiences: work_experiences, user: current_user)
  end

  def index(conn, %{"user_slug" => slug}, _current_user) do
    user = UserProfiles.get_user!(%{"slug" => slug})
    work_experiences = Biographies.list_work_experiences(user)
    render(conn, "index.html", work_experiences: work_experiences, user: user)
  end

  def new(conn, _params, _current_user) do
    changeset = Biographies.change_work_experience(%WorkExperience{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"work_experience" => work_experience_params}, current_user) do
    case Biographies.create_work_experience(current_user, work_experience_params) do
      {:ok, work_experience} ->
        conn
        |> put_flash(:info, gettext("Work experience created successfully."))
        |> redirect(
          to: Routes.user_work_experience_path(conn, :show, current_user, work_experience)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id, "user_slug" => slug}, %User{slug: slug} = current_user) do
    work_experience = Biographies.get_work_experience!(current_user, id)
    render(conn, "show.html", work_experience: work_experience, user: current_user)
  end

  def show(conn, %{"id" => id, "user_slug" => slug}, _current_user) do
    user = UserProfiles.get_user!(%{"slug" => slug})
    work_experience = Biographies.get_work_experience!(user, id)
    render(conn, "show.html", work_experience: work_experience, user: user)
  end

  def edit(conn, %{"id" => id}, current_user) do
    work_experience = Biographies.get_work_experience!(current_user, id)
    changeset = Biographies.change_work_experience(work_experience)
    render(conn, "edit.html", work_experience: work_experience, changeset: changeset)
  end

  def update(conn, %{"id" => id, "work_experience" => work_experience_params}, current_user) do
    work_experience = Biographies.get_work_experience!(current_user, id)

    case Biographies.update_work_experience(work_experience, work_experience_params) do
      {:ok, work_experience} ->
        conn
        |> put_flash(:info, gettext("Work experience updated successfully."))
        |> redirect(
          to: Routes.user_work_experience_path(conn, :show, current_user, work_experience)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", work_experience: work_experience, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    work_experience = Biographies.get_work_experience!(current_user, id)
    {:ok, _work_experience} = Biographies.delete_work_experience(work_experience)

    conn
    |> put_flash(:info, gettext("Work experience deleted successfully."))
    |> redirect(to: Routes.user_work_experience_path(conn, :index, current_user))
  end
end
