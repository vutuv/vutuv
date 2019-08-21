defmodule Vutuv.BiographiesTest do
  use Vutuv.DataCase

  import Vutuv.Factory

  alias Vutuv.{Biographies, Biographies.WorkExperience}

  @create_work_experience_attrs %{
    description: "Testing safety of machines",
    end_date: ~D[2014-04-17],
    organization: "Acme",
    slug: "quality_assurance_supervisor_acme",
    start_date: ~D[2010-04-17],
    title: "Quality assurance supervisor"
  }

  describe "work_experiences" do
    test "list_work_experiences/1 returns all work_experiences" do
      %WorkExperience{user: user} = work = insert(:work_experience)
      [work_1] = Biographies.list_work_experiences(user)
      assert work_1.description == work.description
      assert work_1.title == work.title
    end

    test "get_work_experience!/2 returns the work_experience with given id" do
      %WorkExperience{id: id, user: user} = work = insert(:work_experience)
      work_1 = Biographies.get_work_experience!(user, id)
      assert work_1.description == work.description
      assert work_1.title == work.title
    end

    test "create_work_experience/2 with valid data creates a work_experience" do
      user = insert(:user)

      assert {:ok, %WorkExperience{} = work} =
               Biographies.create_work_experience(user, @create_work_experience_attrs)

      assert work.description =~ "Testing safety of machines"
      assert work.end_date == ~D[2014-04-17]
      assert work.organization =~ "Acme"
      assert work.slug =~ "quality_assurance_supervisor_acme"
      assert work.start_date == ~D[2010-04-17]
      assert work.title =~ "Quality assurance supervisor"
    end

    test "create_work_experience/1 with invalid data returns error changeset" do
      user = insert(:user)

      assert {:error, %Ecto.Changeset{}} =
               Biographies.create_work_experience(user, %{description: nil})
    end

    test "update_work_experience/2 with valid data updates the work_experience" do
      work = insert(:work_experience)
      update_attrs = %{description: "Made the tea"}

      assert {:ok, %WorkExperience{} = work} =
               Biographies.update_work_experience(work, update_attrs)

      assert work.description =~ "Made the tea"
    end

    test "update_work_experience/2 with invalid data returns error changeset" do
      %WorkExperience{user: user} = work = insert(:work_experience)

      assert {:error, %Ecto.Changeset{}} = Biographies.update_work_experience(work, %{title: nil})

      work_1 = Biographies.get_work_experience!(user, work.id)
      assert work_1.title
      assert work.title == work_1.title
    end

    test "delete_work_experience/1 deletes the work_experience" do
      %WorkExperience{user: user} = work = insert(:work_experience)
      assert {:ok, %WorkExperience{}} = Biographies.delete_work_experience(work)

      assert_raise Ecto.NoResultsError, fn ->
        Biographies.get_work_experience!(user, work.id)
      end
    end

    test "change_work_experience/1 returns a work_experience changeset" do
      work = insert(:work_experience)
      assert %Ecto.Changeset{} = Biographies.change_work_experience(work)
    end
  end
end
