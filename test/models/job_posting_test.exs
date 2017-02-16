defmodule Vutuv.JobPostingTest do
  use Vutuv.ModelCase

  alias Vutuv.JobPosting

  @valid_attrs %{closed_on: "some content", description: "some content", location: "some content", open_on: "some content", prerequisites: "some content", recruiter_subscription_id: "some content", slug: "some content", title: "some content", user_id: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = JobPosting.changeset(%JobPosting{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = JobPosting.changeset(%JobPosting{}, @invalid_attrs)
    refute changeset.valid?
  end
end
