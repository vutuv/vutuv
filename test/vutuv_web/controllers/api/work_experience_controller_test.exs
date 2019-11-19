defmodule VutuvWeb.Api.WorkExperienceControllerTest do
  use VutuvWeb.ConnCase

  alias Vutuv.Biographies

  @create_attrs %{
    description: "Testing safety of machines",
    end_date: ~D[2014-04-17],
    organization: "Acme",
    slug: "quality_assurance_supervisor_acme",
    start_date: ~D[2010-04-17],
    title: "Quality assurance supervisor"
  }

  setup %{conn: conn} do
    user = add_user("igor@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "read work_experiences" do
    test "lists a user's work_experiences", %{conn: conn, user: user} do
      work = insert(:work_experience, %{user: user})
      conn = get(conn, Routes.api_user_work_experience_path(conn, :index, user))
      assert [new_work] = json_response(conn, 200)["data"]
      assert new_work == single_response(work)
    end

    test "shows a single work_experience", %{conn: conn, user: user} do
      work = insert(:work_experience, %{user: user})
      conn = get(conn, Routes.api_user_work_experience_path(conn, :show, user, work))
      assert json_response(conn, 200)["data"] == single_response(work)
    end
  end

  describe "write work_experience" do
    setup [:add_token_to_conn]

    test "create work_experience with valid data", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.api_user_work_experience_path(conn, :create, user),
          work_experience: @create_attrs
        )

      assert json_response(conn, 201)["data"]["id"]
      [new_work] = Biographies.list_work_experiences(user)
      assert new_work.description == @create_attrs[:description]
      assert new_work.organization == @create_attrs[:organization]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.api_user_work_experience_path(conn, :create, user),
          work_experience: %{"title" => ""}
        )

      assert json_response(conn, 422)["errors"]["title"] == ["can't be blank"]
    end

    test "update work_experience with valid data", %{conn: conn, user: user} do
      work = insert(:work_experience, %{user: user})

      conn =
        put(conn, Routes.api_user_work_experience_path(conn, :update, user, work),
          work_experience: %{"description" => "Looked after pet tiger"}
        )

      assert json_response(conn, 200)["data"]["id"]
      work = Biographies.get_work_experience!(user, work.id)
      assert work.description =~ "Looked after pet tiger"
    end

    test "does not update work_experience when data is invalid", %{conn: conn, user: user} do
      work = insert(:work_experience, %{user: user})

      conn =
        put(conn, Routes.api_user_work_experience_path(conn, :update, user, work),
          work_experience: %{"title" => ""}
        )

      assert json_response(conn, 422)["errors"]["title"] == ["can't be blank"]
    end
  end

  describe "delete work_experience" do
    setup [:add_token_to_conn]

    test "can delete chosen work_experience", %{conn: conn, user: user} do
      work = insert(:work_experience, %{user: user})
      conn = delete(conn, Routes.api_user_work_experience_path(conn, :delete, user, work))
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn ->
        Biographies.get_work_experience!(user, work.id)
      end
    end

    test "cannot delete another user's work_experience", %{conn: conn, user: user} do
      other = add_user("raymond@example.com")
      work = insert(:work_experience, %{user: other})

      assert_error_sent 404, fn ->
        delete(conn, Routes.api_user_work_experience_path(conn, :delete, user, work))
      end

      assert Biographies.get_work_experience!(other, work.id)
    end
  end

  defp single_response(work_experience) do
    %{
      "id" => work_experience.id,
      "user_id" => work_experience.user_id,
      "description" => work_experience.description,
      "end_date" => Date.to_string(work_experience.end_date),
      "organization" => work_experience.organization,
      "slug" => work_experience.slug,
      "start_date" => Date.to_string(work_experience.start_date),
      "title" => work_experience.title
    }
  end
end
