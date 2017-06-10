defmodule Battlestation.VmMonitor do
  @moduledoc """
  Load all virtual machines running on this box, then store them in memory for display on the frontend.

  Also provides functionality to specify VM's running on other boxes
  """

  use ExActor.GenServer, export: :vm_monitor

  alias Battlestation.Virtualbox

  defstart start_link do
    Virtualbox.stop_all_vms()
    Virtualbox.start_all_vms()
    # todo refresh IP addresses in case there is a double lease
    # Virtualbox.snapshot_all_vms() #todo snapshot if not exists

    vms = Virtualbox.identify_vm_ips()
    |> Enum.reduce(%{}, fn({name, ip}, acc) ->
      Map.put(acc, name, %{name: name, ip_address: ip, running_locally: true})
    end)

    initial_state(vms)
  end

  @doc """
  Adding, but can also be used for updating as long as the VM name has not changed
  """
  defcast add(name, ip_address, running_locally \\ false), state: state do
    state |> Map.put(name, %{name: name, ip_address: ip_address, running_locally: running_locally}) |> new_state()
  end

  defcast remove(name), state: state, do: state |> Map.delete(name) |> new_state()

  defcall get, state: state, do: reply(state)

  defcast stop, do: stop_server(:normal)
end
