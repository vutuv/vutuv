defmodule Mix.Tasks.SendEmails.BirthdayReminder do
  use Mix.Task
  import Mix.Ecto
  import Ecto.Query
  alias Vutuv.Repo
  alias Vutuv.User

  @shortdoc "Send an email in case one of your followers celebrates his/her birthday today."

  def run(_args) do
    Mix.Tasks.App.Start.run([])
    ensure_started(Repo, [])
    users = Repo.all(from u in User, where: u.validated? == true)
            |> Repo.preload([:followees])

    {{year, month, day}, {_, _, _}} = :calendar.local_time()

    for(user <- users) do
      birthday_childs = for(followee <- user.followees) do
        case Ecto.Date.dump(followee.birthdate) do
          {:ok, {_, ^month, ^day}} ->
            followee
          _ ->
            nil
        end
      end

      Vutuv.Emailer.birthday_reminder(user, Enum.reject(birthday_childs, fn(x) -> x == nil end))
      |> Vutuv.Mailer.deliver_now

      IO.puts Bamboo.SentEmail.all()
    end

  end
end
