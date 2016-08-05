defmodule Vutuv.PhoneNumberController do
  use Vutuv.Web, :controller
  plug :auth_user

  alias Vutuv.PhoneNumber

  plug :scrub_params, "phone_number" when action in [:create, :update]

  def index(conn, _params) do
    phone_numbers = Repo.all(assoc(conn.assigns[:user], :phone_numbers))
    render(conn, "index.html", phone_numbers: phone_numbers)
  end

  def new(conn, _params) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:phone_numbers)
      |> PhoneNumber.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"phone_number" => phone_number_params}) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:phone_numbers)
      |> PhoneNumber.changeset(phone_number_params)

    case Repo.insert(changeset) do
      {:ok, _phone_number} ->
        conn
        |> put_flash(:info, "Phone number created successfully.")
        |> redirect(to: user_phone_number_path(conn, :index, conn.assigns[:user]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    phone_number = Repo.get!(assoc(conn.assigns[:user], :phone_numbers), id)
    render(conn, "show.html", phone_number: phone_number)
  end

  def edit(conn, %{"id" => id}) do
    phone_number = Repo.get!(assoc(conn.assigns[:user], :phone_numbers), id)
    changeset = PhoneNumber.changeset(phone_number)
    render(conn, "edit.html", phone_number: phone_number, changeset: changeset)
  end

  def update(conn, %{"id" => id, "phone_number" => phone_number_params}) do
    phone_number = Repo.get!(assoc(conn.assigns[:user], :phone_numbers), id)
    changeset = PhoneNumber.changeset(phone_number, phone_number_params)
    case Repo.update(changeset) do
      {:ok, phone_number} ->
        conn
        |> put_flash(:info, "Phone number updated successfully.")
        |> redirect(to: user_phone_number_path(conn, :show, conn.assigns[:user], phone_number))
      {:error, changeset} ->
        render(conn, "edit.html", phone_number: phone_number, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    phone_number = Repo.get!(assoc(conn.assigns[:user], :phone_numbers), id)
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(phone_number)
    conn
    |> put_flash(:info, "Phone number deleted successfully.")
    |> redirect(to: user_phone_number_path(conn, :index, conn.assigns[:user]))
  end

  defp auth_user(conn, _opts) do
    if(conn.assigns[:user].id == conn.assigns[:current_user].id) do
      conn
    else
      redirect(conn, to: user_path(conn, :show, conn.assigns[:current_user]))
      |> halt
    end
  end
end
