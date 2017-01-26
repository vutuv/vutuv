defmodule Vutuv.Cronjob do
  import Mix.Ecto
  import Ecto.Query
  require Vutuv.Gettext
  alias Vutuv.Repo
  alias Vutuv.User

  def send_birthday_reminders do
    # TODO: Remove where: u.id == 1 after testing
    #
    users = Repo.all(from u in User, where: u.validated? == true, where: u.id == 1) |> Repo.preload([:followees])

    today = Timex.Date.today

    for(user <- users) do
      todays_users = followees_who_have_birthday(user, today)

      # Get the next 10 birthdays within the
      # next 3 weeks.
      #
      future_users = for n <- 1..21 do
        date = Timex.shift(today, days: n)
        followees_who_have_birthday(user, date)
      end
      future_users = List.flatten(future_users)
                     |> Enum.take(5)

      if length(todays_users) > 0 do
        Vutuv.Emailer.birthday_reminder(user, todays_users, future_users)
        |> Vutuv.Mailer.deliver_now
      end
    end
  end

  def followees_who_have_birthday(user, date) do
    month = date.month
    day = date.day

    winners = for(followee <- user.followees) do
      case Ecto.Date.dump(followee.birthdate) do
        {:ok, {_, ^month, ^day}} ->
          followee
        _ ->
          nil
      end
    end

    Enum.reject(winners, fn(x) -> x == nil end)
  end
end
