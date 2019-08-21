defmodule VutuvWeb.WorkExperienceControllerTest do
  use VutuvWeb.ConnCase

  import Vutuv.Factory
  import VutuvWeb.AuthTestHelpers

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
    conn = conn |> bypass_through(VutuvWeb.Router, [:browser]) |> get("/")
    user = add_user("igor@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "read work_experiences" do
    test "lists a user's work_experiences", %{conn: conn, user: user} do
      work = insert(:work_experience, %{user: user})
      conn = get(conn, Routes.user_work_experience_path(conn, :index, user))
      assert html_response(conn, 200) =~ work.description
    end

    test "shows a single work_experience", %{conn: conn, user: user} do
      work = insert(:work_experience, %{user: user})
      conn = get(conn, Routes.user_work_experience_path(conn, :show, user, work))
      assert html_response(conn, 200) =~ work.description
    end
  end

  describe "renders forms" do
    setup [:add_user_session]

    test "new work_experience form", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_work_experience_path(conn, :new, user))
      assert html_response(conn, 200) =~ "New work experience"
    end

    test "edit work_experience form", %{conn: conn, user: user} do
      work = insert(:work_experience, %{user: user})
      conn = get(conn, Routes.user_work_experience_path(conn, :edit, user, work))
      assert html_response(conn, 200) =~ "Edit work experience"
    end
  end

  describe "write work_experience" do
    setup [:add_user_session]

    test "create work_experience with valid data", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_work_experience_path(conn, :create, user),
          work_experience: @create_attrs
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_work_experience_path(conn, :show, user, id)
      assert get_flash(conn, :info) =~ "created successfully"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_work_experience_path(conn, :create, user),
          work_experience: %{"title" => ""}
        )

      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end

    test "update work_experience with valid data", %{conn: conn, user: user} do
      work = insert(:work_experience, %{user: user})

      conn =
        put(conn, Routes.user_work_experience_path(conn, :update, user, work),
          work_experience: %{"description" => "Looked after pet tiger"}
        )

      assert redirected_to(conn) == Routes.user_work_experience_path(conn, :show, user, work)
      assert get_flash(conn, :info) =~ "updated successfully"
      work = Biographies.get_work_experience!(user, work.id)
      assert work.description =~ "Looked after pet tiger"
    end

    test "does not update work_experience when data is invalid", %{conn: conn, user: user} do
      work = insert(:work_experience, %{user: user})

      conn =
        put(conn, Routes.user_work_experience_path(conn, :update, user, work),
          work_experience: %{"title" => ""}
        )

      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end
  end

  describe "delete work_experience" do
    setup [:add_user_session]

    test "can delete chosen work_experience", %{conn: conn, user: user} do
      work = insert(:work_experience, %{user: user})
      conn = delete(conn, Routes.user_work_experience_path(conn, :delete, user, work))
      assert redirected_to(conn) == Routes.user_work_experience_path(conn, :index, user)
      assert get_flash(conn, :info) =~ "deleted successfully"

      assert_raise Ecto.NoResultsError, fn ->
        Biographies.get_work_experience!(user, work.id)
      end
    end

    test "cannot delete another user's work_experience", %{conn: conn, user: user} do
      other = add_user("raymond@example.com")
      work = insert(:work_experience, %{user: other})

      assert_error_sent 404, fn ->
        delete(conn, Routes.user_work_experience_path(conn, :delete, user, work))
      end

      assert Biographies.get_work_experience!(other, work.id)
    end
  end

  defp add_user_session(%{conn: conn, user: user}) do
    conn = conn |> add_session(user) |> send_resp(:ok, "/")
    {:ok, %{conn: conn, user: user}}
  end
end
