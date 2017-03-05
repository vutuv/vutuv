defmodule Vutuv.RecruiterSubscriptionControllerTest do
  use Vutuv.ConnCase

  alias Vutuv.RecruiterSubscription
  @valid_attrs %{city: "some content", country: "some content", invoice_number: "some content", invoiced_on: "some content", line1: "some content", line2: "some content", paid: "some content", paid_on: "some content", recruiter_package_id: "some content", street: "some content", subscription_begins: "some content", subscription_ends: "some content", user_id: "some content", zip_code: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, recruiter_subscription_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing recruiter subscriptions"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, recruiter_subscription_path(conn, :new)
    assert html_response(conn, 200) =~ "New recruiter subscription"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, recruiter_subscription_path(conn, :create), recruiter_subscription: @valid_attrs
    assert redirected_to(conn) == recruiter_subscription_path(conn, :index)
    assert Repo.get_by(RecruiterSubscription, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, recruiter_subscription_path(conn, :create), recruiter_subscription: @invalid_attrs
    assert html_response(conn, 200) =~ "New recruiter subscription"
  end

  test "shows chosen resource", %{conn: conn} do
    recruiter_subscription = Repo.insert! %RecruiterSubscription{}
    conn = get conn, recruiter_subscription_path(conn, :show, recruiter_subscription)
    assert html_response(conn, 200) =~ "Show recruiter subscription"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, recruiter_subscription_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    recruiter_subscription = Repo.insert! %RecruiterSubscription{}
    conn = get conn, recruiter_subscription_path(conn, :edit, recruiter_subscription)
    assert html_response(conn, 200) =~ "Edit recruiter subscription"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    recruiter_subscription = Repo.insert! %RecruiterSubscription{}
    conn = put conn, recruiter_subscription_path(conn, :update, recruiter_subscription), recruiter_subscription: @valid_attrs
    assert redirected_to(conn) == recruiter_subscription_path(conn, :show, recruiter_subscription)
    assert Repo.get_by(RecruiterSubscription, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    recruiter_subscription = Repo.insert! %RecruiterSubscription{}
    conn = put conn, recruiter_subscription_path(conn, :update, recruiter_subscription), recruiter_subscription: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit recruiter subscription"
  end

  test "deletes chosen resource", %{conn: conn} do
    recruiter_subscription = Repo.insert! %RecruiterSubscription{}
    conn = delete conn, recruiter_subscription_path(conn, :delete, recruiter_subscription)
    assert redirected_to(conn) == recruiter_subscription_path(conn, :index)
    refute Repo.get(RecruiterSubscription, recruiter_subscription.id)
  end
end
