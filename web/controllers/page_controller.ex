defmodule Battlestation.PageController do
  use Battlestation.Web, :controller

  require Logger

  alias Battlestation.Virtualbox

  def index(conn, _params) do
    render conn, "index.html", vms: Battlestation.VmMonitor.get()
  end

  def create(conn, params) do
    redirect(conn, to: page_path(conn, :index))
  end

  def update(conn, params) do
    redirect(conn, to: page_path(conn, :index))
  end
end
