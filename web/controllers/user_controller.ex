defmodule Vutuv.UserController do
  use Vutuv.Web, :controller
  plug Vutuv.Plug.UserResolveSlug when action in [:edit, :update, :index, :show, :skills_create]
  plug :logged_in? when action in [:index]
  plug :auth when action in [:edit, :update, :skills_create, :skills_create]
  plug Vutuv.Plug.RequireUserLoggedOut when action in [:new, :create]
  plug Vutuv.Plug.EnsureValidated when not action in [:delete, :magic_delete]
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
        case Vutuv.Auth.login_by_email(conn, email) do
          {:ok, conn} ->
            conn
            |> put_flash(:info, Vutuv.Gettext.gettext("User %{name} created successfully. An email has been sent with your login link.", name: full_name(user)))
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

  def show(conn, _params) do
    total_jobs = count_user_assoc Vutuv.WorkExperience, conn.assigns[:user]
    total_numbers = count_user_assoc Vutuv.PhoneNumber, conn.assigns[:user]
    total_links = count_user_assoc Vutuv.Url, conn.assigns[:user]
    total_addresses = count_user_assoc Vutuv.Address, conn.assigns[:user]
    job_limit = if total_jobs>5, do: 3, else: total_jobs
    number_limit = if total_numbers>5, do: 3, else: total_numbers
    link_limit = if total_links>5, do: 3, else: total_links
    address_limit = if total_addresses>5, do: 3, else: total_addresses
    user = 
      conn.assigns[:user]
      |> Repo.preload([
        :social_media_accounts,
        :followees,
        :followers,
        user_skills: from(u in Vutuv.UserSkill, preload: [:endorsements]),
        followee_connections: {Connection.latest(3), [:followee]},
        follower_connections: {Connection.latest(3), [:follower]},
        phone_numbers: from(u in Vutuv.PhoneNumber, order_by: [desc: u.updated_at], limit: ^number_limit),
        urls: from(u in Vutuv.Url, order_by: [desc: u.updated_at], limit: ^link_limit),
        addresses: from(u in Vutuv.Address, order_by: [desc: u.updated_at], limit: ^address_limit),
        work_experiences: from(u in Vutuv.WorkExperience, order_by: [desc: u.start_year, desc: u.start_month], limit: ^job_limit)
        ])
    user_skills =
      user.user_skills
      |> Enum.sort(&(Enum.count(&1.endorsements)>Enum.count(&2.endorsements)))
      |> Enum.slice(0..3)
    job = current_job(user)
    emails = Vutuv.UserHelpers.emails_for_display(user, conn.assigns[:current_user])

    

    # Display an introduction message for new users
    #
    inserted_at = :calendar.datetime_to_gregorian_seconds(Ecto.DateTime.to_erl(user.inserted_at))
    now = :calendar.datetime_to_gregorian_seconds(:calendar.universal_time)
    display_welcome_message = now - inserted_at <= 600

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
    |> assign(:total_jobs, total_jobs)
    |> assign(:total_numbers, total_numbers)
    |> assign(:total_links, total_links)
    |> assign(:total_addresses, total_addresses)
    |> assign(:display_welcome_message, display_welcome_message)
    |> render("show.html", conn: conn)
  end

  def count_user_assoc(schema, user) do
    Repo.one(from a in schema, where: a.user_id== ^user.id, select: count("*"))
  end

  def edit(conn, _params) do
    user = 
      conn.assigns[:user]
      |> Repo.preload([:emails, :slugs, :oauth_providers])
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    user = conn.assigns[:user]
    user
    |> Repo.preload([:emails, :slugs, :oauth_providers, :search_terms])
    |> User.changeset(user_params)
    |> update_search_terms(user_params)
    |> Repo.update
    |> case do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("User updated successfully."))
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
        |> put_flash(:info, gettext("Slug updated successfully."))
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
        |> put_flash(:info, gettext("User deleted successfully."))
        |> redirect(to: page_path(conn, :index))
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: page_path(conn, :index))
    end
  end

  def delete(conn, _params) do
    Vutuv.MagicLinkHelpers.gen_magic_link(conn.assigns[:current_user], "delete")
    |> Vutuv.Emailer.user_deletion_email(email(conn.assigns[:current_user]), conn.assigns[:current_user])
    |> Vutuv.Mailer.deliver_now
    conn
    |> put_flash(:info, gettext("An email has been sent to your email address with instructions on how to delete your account."))
    |> redirect(to: user_path(conn, :show, conn.assigns[:current_user]))
  end

  def skills_create(conn, %{"skills" => %{"skills" => skills}}) do
    user =
      conn.assigns[:user]
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
    |> put_flash(:info, Vutuv.Gettext.gettext("Successfully added %{successes} skills with %{failures} failures.", successes: Enum.count(skill_list)-failures, failures: failures))
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
        |> put_flash(:info, Vutuv.Gettext.gettext("You follow back %{name}.", name: full_name(user)))
        |> redirect(to: user_path(conn, :show, conn.assigns.current_user))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, Vutuv.Gettext.gettext("Couldn't follow back to %{name}.", name: full_name(user)))
        |> redirect(to: user_path(conn, :show, conn.assigns.current_user))
    end
  end

  defp logged_in?(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, gettext("You must be logged in to access that page"))
      |> redirect(to: page_path(conn, :index))
      |> halt()
    end
  end

  defp auth(conn, _opts) do
    case conn.params do
      %{"slug" => slug} ->
        case Repo.one(from s in Slug, where: s.value == ^slug, select: s.user_id) do
          nil  -> not_found(conn)
          user_id ->
            if(user_id == conn.assigns[:current_user_id]) do
              conn
            else
              conn
              |> put_status(403)
              |> render(Vutuv.ErrorView, "403.html")
              |> halt
            end
        end
      _ -> not_found(conn)
    end
  end

  def not_found(conn) do
    conn
    |> put_status(:not_found)
    |> render(Vutuv.ErrorView, "404.html")
    |> halt
  end
end
