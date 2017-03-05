defmodule Vutuv.RecruiterSubscriptionTest do
  use Vutuv.ModelCase

  alias Vutuv.RecruiterSubscription

  @valid_attrs %{city: "some content", country: "some content", invoice_number: "some content", invoiced_on: "some content", line1: "some content", line2: "some content", paid: "some content", paid_on: "some content", recruiter_package_id: "some content", street: "some content", subscription_begins: "some content", subscription_ends: "some content", user_id: "some content", zip_code: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = RecruiterSubscription.changeset(%RecruiterSubscription{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = RecruiterSubscription.changeset(%RecruiterSubscription{}, @invalid_attrs)
    refute changeset.valid?
  end
end
