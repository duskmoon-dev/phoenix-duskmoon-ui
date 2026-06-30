defmodule QuickBEAM.LockManager do
  @moduledoc false
  use GenServer

  defmodule Lock do
    @moduledoc false
    defstruct [:name, :mode, :holder, :ref]
  end

  defmodule PendingRequest do
    @moduledoc false
    defstruct [:name, :mode, :from, :holder, :ref, :if_available]
  end

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def request_lock(name, mode, holder_pid, if_available \\ false) do
    GenServer.call(__MODULE__, {:request, name, mode, holder_pid, if_available}, :infinity)
  end

  def release_lock(name, holder_pid) do
    GenServer.call(__MODULE__, {:release, name, holder_pid})
  end

  def query do
    GenServer.call(__MODULE__, :query)
  end

  @impl true
  def init(_) do
    {:ok, %{held: [], pending: []}}
  end

  @impl true
  def handle_call({:request, name, mode, holder_pid, if_available}, from, state) do
    ref = Process.monitor(holder_pid)

    if can_grant?(state.held, name, mode) do
      lock = %Lock{name: name, mode: mode, holder: holder_pid, ref: ref}
      {:reply, :granted, %{state | held: [lock | state.held]}}
    else
      if if_available do
        Process.demonitor(ref, [:flush])
        {:reply, :not_available, state}
      else
        pending = %PendingRequest{
          name: name,
          mode: mode,
          from: from,
          holder: holder_pid,
          ref: ref,
          if_available: false
        }

        {:noreply, %{state | pending: state.pending ++ [pending]}}
      end
    end
  end

  def handle_call({:release, name, holder_pid}, _from, state) do
    {released, remaining} =
      Enum.split_with(state.held, fn lock ->
        lock.name == name and lock.holder == holder_pid
      end)

    for lock <- released, do: Process.demonitor(lock.ref, [:flush])

    state = %{state | held: remaining}
    state = try_grant_pending(state)
    {:reply, :ok, state}
  end

  def handle_call(:query, _from, state) do
    held =
      Enum.map(state.held, fn lock ->
        %{name: lock.name, mode: lock.mode}
      end)

    pending =
      Enum.map(state.pending, fn req ->
        %{name: req.name, mode: req.mode}
      end)

    {:reply, %{held: held, pending: pending}, state}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    {released, remaining_held} =
      Enum.split_with(state.held, fn lock -> lock.ref == ref end)

    {cancelled, remaining_pending} =
      Enum.split_with(state.pending, fn req -> req.ref == ref end)

    for req <- cancelled do
      GenServer.reply(req.from, :holder_down)
    end

    state = %{state | held: remaining_held, pending: remaining_pending}

    state =
      if released != [] do
        try_grant_pending(state)
      else
        state
      end

    {:noreply, state}
  end

  defp can_grant?(held, name, mode) do
    existing = Enum.filter(held, &(&1.name == name))

    cond do
      existing == [] -> true
      mode == "shared" -> Enum.all?(existing, &(&1.mode == "shared"))
      true -> false
    end
  end

  defp try_grant_pending(state) do
    {granted, still_pending} =
      Enum.reduce(state.pending, {[], []}, fn req, {granted, pending} ->
        if can_grant?(state.held ++ granted, req.name, req.mode) do
          lock = %Lock{name: req.name, mode: req.mode, holder: req.holder, ref: req.ref}
          GenServer.reply(req.from, :granted)
          {[lock | granted], pending}
        else
          {granted, [req | pending]}
        end
      end)

    %{state | held: state.held ++ granted, pending: Enum.reverse(still_pending)}
  end
end
