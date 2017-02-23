defmodule Vutuv.RecruiterSubscriptionController do
  use Vutuv.Web, :controller

  alias Vutuv.RecruiterSubscription

  def index(conn, _params) do
    user = Repo.preload(conn.assigns[:user], [recruiter_subscriptions: :recruiter_package])
    render(conn, "index.html", recruiter_subscriptions: user.recruiter_subscriptions)
  end

  def new(conn, _params) do
    changeset = RecruiterSubscription.changeset(%RecruiterSubscription{})
    active = RecruiterSubscription.active_subscription(conn.assigns[:user_id])
    packages = Vutuv.RecruiterPackage.get_packages(conn.assigns[:locale])
    render(conn, "new.html", changeset: changeset, active_subscription: active, packages: packages)
  end

  def create(conn, %{"recruiter_subscription" => recruiter_subscription_params}) do
    changeset =
      Ecto.build_assoc(conn.assigns[:user], :recruiter_subscriptions)
      |> RecruiterSubscription.changeset(recruiter_subscription_params)

    case Repo.insert(changeset) do
      {:ok, _recruiter_subscription} ->
        conn
        |> put_flash(:info, gettext("Recruiter subscription created successfully."))
        |> redirect(to: user_recruiter_subscription_path(conn, :new, conn.assigns[:user]))
      {:error, changeset} ->
        packages = Vutuv.RecruiterPackage.get_packages(conn.assigns[:locale])
        render(conn, "new.html", changeset: changeset, packages: packages)
    end
  end

  def show(conn, %{"id" => id}) do
    recruiter_subscription = Repo.get!(RecruiterSubscription, id)
      |> Repo.preload([:recruiter_package])
    render(conn, "show.html", recruiter_subscription: recruiter_subscription)
  end

  def delete(conn, %{"id" => id}) do
    recruiter_subscription = Repo.get!(RecruiterSubscription, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(recruiter_subscription)

    conn
    |> put_flash(:info, gettext("Recruiter subscription deleted successfully."))
    |> redirect(to: user_recruiter_subscription_path(conn, :index, conn.assigns[:user]))
  end
end
