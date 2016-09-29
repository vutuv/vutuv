defmodule Vutuv.EmailController do
  use Vutuv.Web, :controller
  alias Vutuv.Email

  plug Vutuv.Plug.AuthUser when not action in [:magic_create]
  plug :scrub_params, "email" when action in [:create, :update]

  def index(conn, _params) do
    emails = Repo.all(assoc(conn.assigns[:user], :emails))
    emails_counter = length(emails)
    render(conn, "index.html", emails: emails, emails_counter: emails_counter)
  end

  def new(conn, _params) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:emails)
      |> Email.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"email" => email_params}) do
    email = email_params["value"]
    Vutuv.MagicLinkHelpers.gen_magic_link(conn.assigns[:user], "email", email)
    |> Vutuv.Emailer.email_creation_email(email)
    |> Vutuv.Mailer.deliver_now
    |> IO.inspect
    redirect conn, to: page_path(conn, :index)
  end

  def magic_create(conn, %{"magiclink" => link}) do
    Vutuv.MagicLinkHelpers.check_magic_link(link, "email")
    |> case do
      {:ok, email, user} ->
        user
        |> build_assoc(:emails)
        |> Email.changeset(%{value: email})
        |> Repo.insert
        |> case do
          {:ok, _email} ->
            conn
            |> put_flash(:info, "Email created successfully.")
            |> redirect(to: page_path(conn, :index))
          {:error, _changeset} ->
            redirect(conn, to: page_path(conn, :index))
        end
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: page_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    email = Repo.get!(assoc(conn.assigns[:user], :emails), id)
    render(conn, "show.html", email: email)
  end

  def edit(conn, %{"id" => id}) do
    email = Repo.get!(assoc(conn.assigns[:user], :emails), id)
    changeset = Email.changeset(email)
    render(conn, "edit.html", email: email, changeset: changeset)
  end

  def update(conn, %{"id" => id, "email" => email_params}) do
    email = Repo.get!(assoc(conn.assigns[:user], :emails), id)
    changeset = Email.changeset(email, email_params)
    case Repo.update(changeset) do
      {:ok, email} ->
        conn
        |> put_flash(:info, "Email updated successfully.")
        |> redirect(to: user_email_path(conn, :show, conn.assigns[:user], email))
      {:error, changeset} ->
        render(conn, "edit.html", email: email, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    email = Repo.get!(assoc(conn.assigns[:user], :emails), id)
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    case Vutuv.Email.can_delete?(conn.assigns.current_user.id) do
    true ->
      Repo.delete!(email)
      conn
      |> put_flash(:info, "Email deleted successfully.")
      |> redirect(to: user_email_path(conn, :index, conn.assigns[:user]))
    false ->
      conn
      |> put_flash(:error, "Cannot delete final email.")
      |> redirect(to: user_email_path(conn, :index, conn.assigns[:user]))
    end
  end
end
