defmodule Vutuv.Downloads.GravatarWorker do
  @moduledoc """
  GenServer to manage downloads of gravatar images.
  """

  use GenServer

  alias Vutuv.{Accounts, Downloads.TaskSupervisor}

  @downloader Application.get_env(:vutuv, :gravatar_downloader)

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc """
  Adds the gravatar image download to the downloads job list.
  """
  def fetch_gravatar(args) do
    GenServer.cast(__MODULE__, {:download, args})
  end

  @doc """
  Gets the current download state.
  """
  def state do
    GenServer.call(__MODULE__, :state)
  end

  def init(_args) do
    {:ok, %{}}
  end

  def handle_call(:state, _, state) do
    {:reply, state, state}
  end

  def handle_cast({:download, args}, state) do
    %Task{ref: _ref} = download(args)
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, _, _pid, _normal}, state) do
    {:noreply, state}
  end

  def handle_info({_ref, {:error, _args}}, state) do
    {:noreply, state}
  end

  def handle_info({_ref, {:ok, changes}}, state) do
    Process.send_after(self(), {:update_db, changes}, 5_000)
    {:noreply, state}
  end

  def handle_info({:update_db, changes}, state) do
    add_gravatar_to_user(changes)
    {:noreply, state}
  end

  defp download(args) do
    Task.Supervisor.async_nolink(TaskSupervisor, fn -> @downloader.run(args) end)
  end

  defp add_gravatar_to_user(%{user_id: user_id, data: changes}) do
    if user = Accounts.get_user(%{"id" => user_id}) do
      Accounts.update_user(user, %{"avatar" => changes})
    end
  end
end
