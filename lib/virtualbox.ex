defmodule Battlestation.Virtualbox do

  @doc """
  Identify IP Addresses of running VMs if possible
  """
  def identify_vm_ips do
    list_vms()
    |> Enum.map(fn(vm_name) ->
      case get_ip_by_guest_property(vm_name) do
        {:ok, ip_address} -> {vm_name, ip_address}
        {:error, :unknown_ip} -> {vm_name, :unknown_ip}
      end
    end)
  end

  @doc """
  Start all known VMs
  """
  def start_all_vms do
    list_vms()
    |> Enum.map(&start_vm(&1))
  end

  @doc """
  Stop all running VMs
  """
  def stop_all_vms do
    list_vms()
    |> Enum.map(&stop_vm(&1))
  end

  @doc """
  Snapshot all VMs
  """
  def snapshot_all_vms do
    list_vms()
    |> Enum.map(&snapshot_vm(&1))
  end

  @doc """
  Restore all VMs from last restore-point
  """
  def restore_all_vms do
    list_vms()
    |> Enum.map(&restore_vm_from_latest(&1))
  end

  @doc """
  Start an offline VM

  VBoxManage startvm [name]
  """
  def start_vm(vm_name) do
    case System.cmd("VBoxManage", ["startvm", vm_name, "--type", "headless"]) do
      {_state_change_msg, 0} -> {:ok, :powering_on}
      {"", 1} -> {:ok, :already_on}
    end
  end

  @doc """
  Stop an online VM

  VBoxManage controlvm [name] poweroff
  """
  def stop_vm(vm_name) do
    case System.cmd("VBoxManage", ["controlvm", vm_name, "poweroff"]) do
      {"", 0} -> {:ok, :vm_off}
      {"", 1} -> {:ok, :already_off}
    end
  end

  @doc """
  Stop the VM (if it's running), clone the VM, then restart the original

  VBoxManage clonevm [name]
  """
  def clone_vm(vm_name) do
    with {:ok, _off_state} <- stop_vm(vm_name),
      {clone_success_msg, 0} <- System.cmd("VBoxManage", ["clonevm", vm_name]),
      {:ok, _start_state} <- start_vm(vm_name),
      cloned_vm_name <- capture(clone_success_msg, ~r/\"(.*)\"\n/, 0)
    do
      {:ok, cloned_vm_name}
    else
      e -> e
    end
  end

  @doc """
  Take a snapshot of a VM
  VBoxManage snapshot [name] take --live

  Returns UUID of snapshot, save this for restores
  """
  def snapshot_vm(vm_name) do
    case System.cmd("VBoxManage", ["snapshot", vm_name, "take", "--live"]) do
      {result, 0} ->
        result
        |> capture(~r/: (.*)\n/, 0)
    end
  end

  @doc """
  Get snapshots associated with a VM

  VBoxManage snapshot [name] list

  # This machine does not have any snapshots
  """
  def get_snapshots(vm_name) do
    case System.cmd("VBoxManage", ["snapshot", vm_name, "list"]) do
      {"This machine does not have any snapshots\n", 1} -> []
      {snapshots, 0} ->
        snapshots
        |> String.split("\n")
        |> Enum.map(&capture(&1, ~r/UUID: (.*)\)/, 0))
        |> Enum.reject(fn(snapshot) -> snapshot == nil end)
    end
  end

  @doc """
  Restore from most recent snapshot
  """
  def restore_vm_from_latest(vm_name) do
    vm_name
    |> get_snapshots()
    |> List.first()
    |> (fn(latest_restore_uuid) ->
      restore_vm(vm_name, latest_restore_uuid)
    end).()
  end

  @doc """
  Power a VM down (if it's not already down), restore a snapshot of a VM, restart the VM
  VBoxManager snapshot [name] restore [restore_uuid]
  """
  def restore_vm(vm_name, restore_uuid) do
    with {:ok, _new_state} <- stop_vm(vm_name),
      {_success_msg, 0} <- System.cmd("VBoxManage", ["snapshot", vm_name, "restore", restore_uuid]),
      {:ok, _start_success} <- start_vm(vm_name)
    do
      {:ok, :restored}
    else
      _e -> {:error, :unable_to_restore}
    end
  end

  @doc """
  Get a list of the running VM names
  """
  def list_vms do
    case System.cmd("VBoxManage", ["list", "vms"]) do
      {vms, 0} ->
        vms
        |> String.split("\n")
        |> Enum.map(fn(vm_name_hash) ->
          vm_name_hash
          |> capture(~r/\"(.*)\"/, 0)
        end)
        |> Enum.reject(fn(vm) -> vm == nil end)
    end
  end

  @doc """
  Experimental, get IP Address of VM by Arp pairing
  """
  def get_ip_by_arp(vm_name) do
    case System.cmd("bash", [System.cwd <> "/scripts/mac-to-ip.sh", vm_name]) do
      res -> res
    end
  end

  @doc """
  Get IP Address of a vm by the guest property (a VirtualBox feature)
  """
  def get_ip_by_guest_property(vm_name) do
    case System.cmd("bash", [System.cwd <> "/scripts/guest-property-get-ip.sh", vm_name]) do
      {"No value set!\n", 0} -> {:error, :unknown_ip}
      {ip_address, 0} ->
        ip_address
        |> String.trim("\n")
        |> (fn(ip_clean) -> {:ok, ip_clean} end).()
      _ ->
        {:error, :unknown_ip}
    end
  end

  @doc """
  Regex helper Fn
  """
  def capture(str, _, _) when str in [nil, ""], do: nil
  def capture(str, pattern, idx) when is_binary(str) and idx >= 0 do
      captures = Regex.scan(pattern, str, capture: :all_but_first)
                        |> List.flatten
                        |> Enum.drop(idx)
      case captures do
        nil -> nil
        []  -> nil
        [h|_] -> h
      end
  end
end
