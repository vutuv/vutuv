defmodule Vutuv.RecruiterPackageTest do
  use Vutuv.ModelCase

  alias Vutuv.RecruiterPackage

  @valid_attrs %{auto_renewal: "some content", currency: "some content", description: "some content", duration_in_months: "some content", locale_id: "some content", max_job_postings: "some content", name: "some content", offer_begins: "some content", offer_ends: "some content", price: "some content", slug: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = RecruiterPackage.changeset(%RecruiterPackage{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = RecruiterPackage.changeset(%RecruiterPackage{}, @invalid_attrs)
    refute changeset.valid?
  end
end
