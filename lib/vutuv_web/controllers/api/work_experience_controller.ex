defmodule VutuvWeb.Api.WorkExperienceController do
  use VutuvWeb, :controller

  import VutuvWeb.Authorize

  alias Vutuv.{Biographies, Biographies.WorkExperience, UserProfiles, UserProfiles.User}

  def action(conn, _), do: auth_action_slug(conn, __MODULE__, [:index, :show])

  action_fallback VutuvWeb.Api.FallbackController

  def index(conn, %{"user_slug" => slug}, %User{slug: slug} = current_user) do
    work_experiences = Biographies.list_work_experiences(current_user)
    render(conn, "index.json", work_experiences: work_experiences)
  end

  def index(conn, %{"user_slug" => slug}, _current_user) do
    user = UserProfiles.get_user!(%{"slug" => slug})
    work_experiences = Biographies.list_work_experiences(user)
    render(conn, "index.json", work_experiences: work_experiences)
  end

  def create(conn, %{"work_experience" => work_experience_params}, current_user) do
    with {:ok, %WorkExperience{} = work_experience} <-
           Biographies.create_work_experience(current_user, work_experience_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        Routes.api_user_work_experience_path(conn, :show, current_user, work_experience)
      )
      |> render("show.json", work_experience: work_experience)
    end
  end

  def show(conn, %{"id" => id, "user_slug" => slug}, %User{slug: slug} = current_user) do
    work_experience = Biographies.get_work_experience!(current_user, id)
    render(conn, "show.json", work_experience: work_experience)
  end

  def show(conn, %{"id" => id, "user_slug" => slug}, _current_user) do
    user = UserProfiles.get_user!(%{"slug" => slug})
    work_experience = Biographies.get_work_experience!(user, id)
    render(conn, "show.json", work_experience: work_experience)
  end

  def update(conn, %{"id" => id, "work_experience" => work_experience_params}, current_user) do
    work_experience = Biographies.get_work_experience!(current_user, id)

    with {:ok, %WorkExperience{} = work_experience} <-
           Biographies.update_work_experience(work_experience, work_experience_params) do
      render(conn, "show.json", work_experience: work_experience)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    work_experience = Biographies.get_work_experience!(current_user, id)

    with {:ok, %WorkExperience{}} <- Biographies.delete_work_experience(work_experience) do
      send_resp(conn, :no_content, "")
    end
  end
end
