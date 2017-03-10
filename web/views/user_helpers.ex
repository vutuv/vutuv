defmodule Vutuv.UserHelpers do
  import Ecto.Query
  import Ecto
  alias Vutuv.User
  alias Vutuv.Repo
  alias Vutuv.Tag
  alias Vutuv.UserTag
  alias Vutuv.WorkExperience
  alias Vutuv.Connection
  alias Vutuv.Address

  def full_name(%User{first_name: first_name,
                      last_name: last_name,
                      honorific_prefix: honorific_prefix,
                      honorific_suffix: honorific_suffix}) do
    [honorific_prefix, first_name, last_name, honorific_suffix]
    |> Enum.reject(&(&1 == "" || &1 == nil))
    |> Enum.join(" ")
  end

  def first_and_last(%User{first_name: first_name, last_name: last_name}, seperator \\ " ") do
    "#{first_name}#{
      if first_name && last_name, do: seperator
      }#{last_name}"
  end

  def name_for_email_to_field(%User{first_name: first_name,
                      last_name: last_name}) do
    [first_name, last_name]
    |> Enum.reject(&(&1 == "" || &1 == nil))
    |> Enum.join(" ")
    |> String.replace(",", "")
    |> String.replace("<", "")
    |> String.replace(">", "")
    |> String.replace("@", "")
    |> String.replace("  ", " ")
  end

  def short_name(%User{first_name: nil, last_name: nil}), do: ""

  def short_name(%User{first_name: nil, last_name: last_name}) do
    String.capitalize(last_name)
  end

  def short_name(%User{first_name: first_name}) do
    String.capitalize(first_name)
  end





  def gravatar_url(user) do
    user = Vutuv.Repo.preload(user, [:emails])
    case user.emails do
      [email | _tail] -> "http://www.gravatar.com/avatar/#{email.md5sum}"
      _               -> nil
    end
  end



  def email(%User{id: id}) do
    Repo.one(from e in Vutuv.Email, where: e.user_id == ^id, limit: 1, select: e.value)
  end



  def users_by_email(email) do
    Repo.all(from u in Vutuv.User, join: e in assoc(u, :emails), where: e.value == ^email)
  end



  def emails_for_display(user, visitor) do
    if(user_has_permissions? user, visitor) do
      Repo.all(assoc(user, :emails))
    else
      Repo.all(from e in assoc(user, :emails), where: e.public?)
    end
  end

  def user_has_permissions?(user, visitor) do
    user_follows_user?(user, visitor) || same_user?(user, visitor)
  end



  def current_job(user) do
    if(Repo.one(from w in WorkExperience,
        join: u in assoc(w, :user),
        where: u.id == ^user.id,
        select: count("*")) > 0) do
      user
      |> has_start_no_end
      |> no_start_no_end(user)
      |> most_recent_job(user)
    end
  end

  defp has_start_no_end(user) do
    Repo.one(from w in WorkExperience,
      join: u in assoc(w, :user),
      where:
        u.id == ^user.id #belongs to user
        and (w.start_month and w.start_year) #has a start date
        and is_nil(w.end_month) and is_nil(w.end_year), #has no end date
      limit: 1)
  end

  defp no_start_no_end(nil, user) do
    Repo.one(from w in WorkExperience,
      join: u in assoc(w, :user),
      where:
        u.id == ^user.id #belongs to user
        and is_nil(w.end_month) and is_nil(w.end_year), #has no end date
      limit: 1)
  end

  defp no_start_no_end(job, _), do: job

  defp most_recent_job(nil, user) do
    Repo.one(from w in WorkExperience,
      join: u in assoc(w, :user),
      where:
        u.id == ^user.id, #belongs to user
      limit: 1,
      order_by: [desc: w.start_year, desc: w.start_month])
  end

  defp most_recent_job(job, _), do: job


  def meta_description(nil, _), do: ""
  def meta_description(_, nil), do: ""

  def meta_description(user, tags) do
    case {work_information_string(user), tags_to_string(tags)} do
      {"", ""} ->
        []
      {"", tags} ->
        ["tags: ", tags]
      {work, ""} ->
        [work]
      {work, tags} ->
        [work, ". tags: ", tags]
    end
  end

  def tags_to_string(tags) do
    for(tag <- tags) do
      UserTag.resolve_name(tag, "en")
    end
    |> Enum.join(", ")
  end

  def work_information_string(user, len \\ 256)

  def work_information_string(nil, _), do: ""

  def work_information_string(user, len) do
    job = current_title(user)
    org = current_organization(user)
    "#{job}#{if (org && (org != "")), do: " @ #{org}"}"
    |> validate_length(job, org, len)
    |> validate_backup(job, org, len)
  end

  defp validate_length(str, job, _org, len) do
    if(String.length(str)>len) do
      "#{job}"
    else
      str
    end
  end

  defp validate_backup(str, job, org, len) when len<=3 do
    validate_backup(str, job, org, 3)
  end

  defp validate_backup(str, job, _org, len) when len>=3 do
    if(String.length(str)>len) do
      "#{job |> String.slice(0, len-3)}..."
    else
      str
    end
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
    Repo.one(from c in Connection, join: u in assoc(c, :follower), where: (is_nil(u.validated?) or u.validated? == true) and c.followee_id == ^user.id, select: count("follower_id"))
  end

  def followee_count(user) do
    Repo.one(from c in Connection, join: u in assoc(c, :followee), where: (is_nil(u.validated?) or u.validated? == true) and c.follower_id == ^user.id, select: count("followee_id"))
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

  def user_follows_user?(_, _), do: false;



  def is_visitor?(_, nil), do: false

  def is_visitor?(conn, current_user) do
    !same_user?(conn.assigns[:user], current_user)
  end



  def same_user?(%User{id: id}, %User{id: id}), do: true
  def same_user?(_, _), do: false



  def format_address(%Address{country: "United States", line_1: line_1, line_2: line_2, city: city, state: state, zip_code: zip_code}) do
    "#{line_1}#{if line_2, do: "\n"<>line_2}
    #{city}, #{state} #{zip_code}
    United States"
    |> Phoenix.HTML.Format.text_to_html
  end

  def format_address(%Address{country: "Germany", line_1: nil, line_2: nil, city: nil, zip_code: nil}) do
    "Deutschland"
    |> Phoenix.HTML.Format.text_to_html
  end

  def format_address(%Address{country: "Germany", line_1: line_1, line_2: line_2, city: city, zip_code: zip_code}) do
    "#{line_1}#{if line_2, do: "\n"<>line_2}
    #{zip_code} #{city}\nDeutschland"
    |> Phoenix.HTML.Format.text_to_html
  end

   def format_address(%Address{country: country, line_1: line_1, line_2: line_2, city: city, zip_code: zip_code}) do
    "#{line_1}#{if line_2, do: "\n"<>line_2}
    #{zip_code} #{city}
    #{country}"
    |> Phoenix.HTML.Format.text_to_html
   end



  def gen_breadcrumbs(args) do
    Enum.reduce(tl(args), gen_breadcrumb(hd(args)), fn f, acc ->
      "#{acc} / #{gen_breadcrumb(f)}"
    end)
    |> Phoenix.HTML.raw
  end

  defp gen_breadcrumb({value, href}) do
    Phoenix.HTML.Link.link(value, to: href, class: "breadcrumbs__link")
    |> Phoenix.HTML.safe_to_string
  end

  defp gen_breadcrumb(value) do
    value
  end



  def format_birthdate(%User{locale: "de", birthdate: birthdate}) do
    format_pyramid Ecto.Date.dump(birthdate)
  end

  def format_birthdate(%User{locale: "en", birthdate: birthdate}) do
    format_USA Ecto.Date.dump(birthdate)
  end

  defp format_pyramid({:ok, {year, month, day}}) do
    "#{String.rjust(Integer.to_string(day), 2, ?0)}.#{String.rjust(Integer.to_string(month), 2, ?0)}.#{year}"
  end

  defp format_pyramid(_), do: ""

  defp format_USA({:ok, {year, month, day}}) do
    "#{String.rjust(Integer.to_string(month), 2, ?0)}/#{String.rjust(Integer.to_string(day), 2, ?0)}/#{year}"
  end

  defp format_USA(_), do: ""




  def email_greeting(%User{locale: "de", last_name: nil}), do: "#{greeting("de")}"

  def email_greeting(%User{locale: "de", gender: "male", last_name: last_name}) do
    "#{greeting("de")} Herr #{last_name}"
  end

  def email_greeting(%User{locale: "de", gender: "female", last_name: last_name}) do
    "#{greeting("de")} Frau #{last_name}"
  end

  def email_greeting(%User{locale: "de", gender: _}), do: "#{greeting("de")}"

  def email_greeting(%User{locale: "en", first_name: nil}), do: "Hi"

  def email_greeting(%User{locale: "en", first_name: first_name}), do: "Hi #{first_name}"

  def email_greeting(_), do: "Hi"


  def greeting("de") do
     {{_, _, _}, {hour, _, _}} = :calendar.local_time()

     case hour do
       1 ->
         "Guten Morgen"
       2 ->
         "Guten Morgen"
       3 ->
         "Guten Morgen"
       4 ->
         "Guten Morgen"
       5 ->
         "Guten Morgen"
       6 ->
         "Guten Morgen"
       7 ->
         "Guten Morgen"
       8 ->
         "Guten Morgen"
       9 ->
         "Guten Morgen"
       10 ->
         "Guten Morgen"
       11 ->
         "Hallo"
       12 ->
         "Hallo"
       13 ->
         "Hallo"
       14 ->
         "Hallo"
       15 ->
         "Hallo"
       16 ->
         "Hallo"
       17 ->
         "Hallo"
       18 ->
         "Guten Abend"
       19 ->
         "Guten Abend"
       20 ->
         "Guten Abend"
       21 ->
         "Guten Abend"
       22 ->
         "Guten Abend"
       23 ->
         "Guten Abend"
       0 ->
         "Guten Abend"
       _ ->
         "Hallo"
     end
  end

  def greeting(_) do
    "Hi"
  end

  def admin_visitor?(conn) do
    admin?(conn.assigns[:current_user])
  end

  defp admin?(%User{administrator: admin}), do: admin

  defp admin?(_), do: false

  def has_tag?(%User{id: user_id}, %Tag{id: tag_id}) do
    !is_nil Repo.one(from u in UserTag, where: u.user_id == ^user_id and u.tag_id == ^tag_id)
  end

  def has_tag?(_, _), do: false
end
