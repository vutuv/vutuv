defmodule Vutuv.UserHelpers do
  import Ecto.Query
  alias Vutuv.User
  alias Vutuv.Repo
  alias Vutuv.WorkExperience
  alias Vutuv.Connection

  def full_name(%User{first_name: first_name,
                      last_name: last_name,
                      honorific_prefix: honorific_prefix,
                      honorific_suffix: honorific_suffix}) do
    [honorific_prefix, first_name, last_name, honorific_suffix]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join(" ")
  end

  def gravatar_url(user) do
    user = Vutuv.Repo.preload(user, [:emails])
    case user.emails do
      [email | _tail] -> "http://www.gravatar.com/avatar/#{email.md5sum}"
      _               -> nil
    end
  end

  def email(user, index \\ 0) do
    Repo.preload(user, [:emails]).emails
    |>case do
      [] -> ""
      nil -> ""
      emails -> Enum.at(emails, index, %{value: ""}).value
    end
  end

  def users_by_email(email) do
    Repo.all(from u in Vutuv.User, join: e in assoc(u, :emails), where: e.value == ^email)
  end

  def current_job(user) do
    Repo.one(from w in WorkExperience, 
      join: u in assoc(w, :user),
      where:
        u.id == ^user.id #belongs to user
        and (w.start_month and w.start_year) #has a start date
        and is_nil(w.end_month) and is_nil(w.end_year), #has no end date
      limit: 1)
  end

  def current_organization(nil), do: ""

  def current_organization(%User{}=user) do
    current_organization(current_job(user))
  end

  def current_organization(%WorkExperience{organization: nil}), do: ""

  def current_organization(%WorkExperience{organization: org}), do: org

  def current_title(nil), do: ""

  def current_title(%User{}=user) do
    current_title(current_job(user))
  end

  def current_title(%WorkExperience{title: nil}), do: ""

  def current_title(%WorkExperience{title: org}), do: org

  def follower_count(user) do
    Repo.one(from c in Connection, where: c.followee_id == ^user.id, select: count("follower_id"))
  end

  def followee_count(user) do
    Repo.one(from c in Connection, where: c.follower_id == ^user.id, select: count("followee_id"))
  end

  def username(user) do
    Repo.one(from s in Vutuv.SocialMediaAccount, 
      join: u in assoc(s, :user),
      where:
        u.id == ^user.id, #belongs to user
      limit: 1)
    |> case do
      nil -> ""
      account -> account.value
    end
  end

  def locale(conn, %User{locale: nil}) do
    conn.assigns[:locale]
  end

  def locale(_conn, %User{locale: locale}) do
    locale
  end

  def user_follows_user?(%User{id: follower_id}, %User{id: followee_id}) do
    Repo.one(from c in Vutuv.Connection, where: c.follower_id==^follower_id and c.followee_id==^followee_id, select: c.id)
  end
end
