defmodule Battlestation.PageController do
  use Battlestation.Web, :controller

  require Logger

  alias Battlestation.Virtualbox
  alias Battlestation.VmMonitor

  def index(conn, _params) do
    render conn, "index.html", vms: VmMonitor.get()
  end

  def create(conn, params) do
    redirect(conn, to: page_path(conn, :index))
  end

  def update(conn, %{"vm" => %{"vm_name" => vm_name, "ip_address" => ip_address, "running_locally" => running_locally}}) do
    VmMonitor.add(vm_name, ip_address, str_to_bool(running_locally))

    json(conn, %{ok: true})
  end

  defp str_to_bool("true"), do: true
  defp str_to_bool(_), do: false
end
