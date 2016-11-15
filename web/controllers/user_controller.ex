defmodule Vutuv.UserController do
  use Vutuv.Web, :controller
  plug :resolve_slug when action in [:edit, :update, :index, :show, :skills_create]
  plug :logged_in? when action in [:index, :show]
  plug :auth when action in [:edit, :update, :skills_create, :skills_create]
  plug Vutuv.Plug.RequireUserLoggedOut when action in [:new, :create]
  import Vutuv.UserHelpers
  use Arc.Ecto.Schema

  alias Vutuv.Slug
  alias Vutuv.User
  alias Vutuv.UserSkill
  alias Vutuv.Skill
  alias Vutuv.Email
  alias Vutuv.Connection

  plug :scrub_params, "user" when action in [:create, :update]

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset =
      User.changeset(%User{})
      |> Ecto.Changeset.put_assoc(:emails, [%Email{}])
    render(conn, "new.html", changeset: changeset, conn: conn)
  end

  def create(conn, %{"user" => user_params}) do
    email = user_params["emails"]["0"]["value"]
    case Vutuv.Registration.register_user(conn, user_params) do
      {:ok, user} ->
        store_gravatar(user)
        case Vutuv.Auth.login_by_email(conn, email) do
          {:ok, conn} ->
            conn
            |> put_flash(:info, "User #{full_name(user)} created successfully. An email has been sent with your login link.")
            |> redirect(to: page_path(conn, :new_registration))
          {:error, _reason, conn} ->
            conn
            |> put_flash(:error, gettext("There was an error"))
            |> redirect(to: page_path(conn, :index))
        end
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  # This downloads and stores a users gravatar. It then updates
  # the user's model with the information for arc-ecto to
  # retrieve the file later. If they do not have one, it stores
  # the default gravatar avatar. It times out at 1 second.

  def store_gravatar(user) do
    case HTTPoison.get("https://www.gravatar.com/avatar/#{hd(user.emails).md5sum}?s=130&d=404", [], [timeout: 1000, recv_timeout: 1000])  do
      {:ok, %HTTPoison.Response{status_code: 404}} -> nil
      {:ok, %HTTPoison.Response{body: body, headers: headers}} ->
        content_type = find_content_type(headers)
        filename = "/#{user.active_slug}.#{String.replace(content_type,"image/", "")}"
        path = System.tmp_dir
        upload = #create the upload struct that arc-ecto will use to store the file and update the database
          %Plug.Upload{content_type: content_type,
          filename: filename,
          path: path<>filename}
        File.write(path<>filename, body) #Write the file temporarily to the disk
        user
        |> Repo.preload([:slugs, :oauth_providers, :emails])
        |> User.changeset(%{avatar: upload}) #update the user with the upload struct
        |> Repo.update
      _ -> nil
    end
  end

  defp find_content_type(headers) do
    Enum.reduce(headers, fn {k, v}, acc ->
      if (k == "Content-Type"), do: v, else: acc
    end)
  end

  def show(conn, _params) do
    user =
      Repo.get!(User, conn.assigns[:user_id])
      |> Repo.preload([
        :social_media_accounts,
        user_skills: from(u in Vutuv.UserSkill, preload: [:endorsements]),
        followee_connections: {Connection.latest(3), [:followee]},
        follower_connections: {Connection.latest(3), [:follower]},
        phone_numbers: from(u in Vutuv.PhoneNumber, order_by: [desc: u.updated_at], limit: 3),
        urls: from(u in Vutuv.Url, order_by: [desc: u.updated_at], limit: 3),
        addresses: from(u in Vutuv.Address, order_by: [desc: u.updated_at], limit: 3),
        work_experiences: from(u in Vutuv.WorkExperience, order_by: [desc: u.updated_at], limit: 3)
        ])
    user_skills =
      user.user_skills
      |> Enum.sort(&(Enum.count(&1.endorsements)>Enum.count(&2.endorsements)))
      |> Enum.slice(0..3)
    job = current_job(user)
    emails = Vutuv.UserHelpers.emails_for_display(user, conn.assigns[:current_user])
    conn
    |> assign(:emails, emails)
    |> assign(:user_skills, user_skills)
    |> assign(:work_experience, user.work_experiences)
    |> assign(:follower_count, follower_count(user))
    |> assign(:followee_count, followee_count(user))
    |> assign(:user, user)
    |> assign(:job, job)
    |> assign(:organization, current_organization(job))
    |> assign(:title, current_title(job))
    |> render("show.html", conn: conn)
  end

  def edit(conn, _params) do
    user = Repo.get!(User, conn.assigns[:user_id]) |> Repo.preload([:emails, :slugs, :oauth_providers])
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    user = Repo.get!(User, conn.assigns[:user_id])
    user
    |> Repo.preload([:emails, :slugs, :oauth_providers, :search_terms])
    |> User.changeset(user_params)
    |> update_search_terms(user_params)
    |> Repo.update
    |> case do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def update_search_terms(changeset, params) do
    first_name = Ecto.Changeset.get_change(changeset, :first_name)
    last_name = Ecto.Changeset.get_change(changeset, :last_name)
    if(first_name || last_name) do #if first or last name is changed, update search terms
      Ecto.Changeset.put_assoc(changeset, :search_terms, Vutuv.SearchTerm.create_search_terms(params))
    else
      changeset
    end
  end

  def insert_slug(conn, %{"id" => id, "params" => params}) do
    user = Repo.get!(User, id)
    slug_changeset = Slug.changeset(%Slug{user_id: id}, params)
    case Repo.insert(slug_changeset) do
      {:ok, _slug} ->
        conn
        |> put_flash(:info, "Slug updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, _changeset} ->
        changeset = User.changeset(user)
        render(conn, "edit.html", user: user, changeset: changeset, slug_changeset: slug_changeset)
      end
  end

  def magic_delete(conn, %{"magiclink" => link}) do
    case Vutuv.MagicLinkHelpers.check_magic_link(link, "delete") do
      {:ok, user} ->
        # Here we use delete! (with a bang) because we expect
        # it to always work (and if it does not, it will raise).
        Repo.delete!(user)

        conn
        |> Vutuv.Auth.logout
        |> put_flash(:info, "User deleted successfully.")
        |> redirect(to: page_path(conn, :index))
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: page_path(conn, :index))
    end
  end

  def delete(conn, _params) do
    link = Vutuv.MagicLinkHelpers.gen_magic_link(conn.assigns[:current_user], "delete")
    url = 
      Application.get_env(:vutuv, Vutuv.Endpoint)[:url]
      |> Keyword.get(:host)
    conn
    |> put_flash(:info, url<>link)
    |> redirect(to: user_path(conn, :show, conn.assigns[:current_user]))
  end

  def skills_create(conn, %{"skills" => %{"skills" => skills}}) do
    user = 
      Repo.get!(User, conn.assigns[:user_id])
      |> Repo.preload([user_skills: [:skill]])
    skill_list = 
      skills
      |> String.split(",")
    results = 
      for(skill <- skill_list) do
        downcase_skill = 
          skill
          |> String.trim
          |> String.downcase
        case Repo.one(from s in Skill, where: s.downcase_name == ^downcase_skill) do
          nil ->
            skill_changeset = Skill.changeset(%Skill{},%{"name" => String.trim(skill)})
            user
            |> Ecto.build_assoc(:user_skills, %{})
            |> UserSkill.changeset
            |> Ecto.Changeset.put_assoc(:skill, skill_changeset)
          existing_skill ->
            user
            |> Ecto.build_assoc(:user_skills, %{skill_id: existing_skill.id})
            |> UserSkill.changeset
        end
        |> Repo.insert
      end
    failures = 
      Enum.reduce(results, 0, fn {result, _}, acc ->
        case result do
          :error -> acc+1
          :ok -> acc
        end
      end)
    conn
    |> put_flash(:info, "Successfully added #{Enum.count(skill_list)-failures} skills with #{failures} failures.")
    |> redirect(to: user_path(conn, :show, user)) 
  end

  def follow_back(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    changeset = Connection.changeset(%Connection{},%{follower_id: conn.assigns.current_user.id, followee_id: user.id})

    conn
    |> assign(:page_title, full_name(user))
    |> assign(:user, user)

    case Repo.insert(changeset) do
      {:ok, _connection} ->
        conn
        |> put_flash(:info, "You follow back #{full_name(user)}.")
        |> redirect(to: user_path(conn, :show, conn.assigns.current_user))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Couldn't follow back to #{full_name(user)}.")
        |> redirect(to: user_path(conn, :show, conn.assigns.current_user))
    end
  end

  def resolve_slug(conn, _opts) do
    case conn.params do
      %{"slug" => slug} ->
        case Repo.one(from s in Slug, where: s.value == ^slug) do
          nil  -> invalid_slug(conn)
          %{disabled: false, user_id: user_id} ->
            user = Repo.get!(Vutuv.User, user_id)
            if(user.active_slug != slug) do
              redirect(conn, to: user_path(conn, :show, user))
            else
              assign(conn, :user_id, user_id)
            end
          _ -> invalid_slug(conn)
        end
      _ -> invalid_slug(conn)
    end
  end

  def invalid_slug(conn) do
    conn
    |> put_status(:not_found)
    |> render(Vutuv.ErrorView, "404.html")
    |> halt
  end

  defp logged_in?(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: page_path(conn, :index))
      |> halt()
    end
  end

  defp auth(conn, _opts) do
    case conn.params do
      %{"slug" => slug} ->
        case Repo.one(from s in Slug, where: s.value == ^slug, select: s.user_id) do
          nil  -> invalid_slug(conn)
          user_id ->
            if(user_id == conn.assigns[:current_user].id) do
              conn
            else
              conn
              |> put_status(403)
              |> render(Vutuv.ErrorView, "403.html")
              |> halt
            end
        end
      _ -> invalid_slug(conn)
    end
  end
end
