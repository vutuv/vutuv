defmodule Vutuv.JobPostingTagTest do
  use Vutuv.ModelCase

  alias Vutuv.JobPostingTag

  @valid_attrs %{job_posting_id: "some content", priority: "some content", tag_id: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = JobPostingTag.changeset(%JobPostingTag{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = JobPostingTag.changeset(%JobPostingTag{}, @invalid_attrs)
    refute changeset.valid?
  end
end
