defmodule Battlestation.PageView do
  use Battlestation.Web, :view

  def is_local?(%{running_locally: true}), do: true
  def is_local?(_), do: false

  def display_ip(ip) when is_atom(ip) do
    ip
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
  def display_ip(ip), do: ip

  def get_errors(changeset, atom) do
    case ! is_nil(changeset.errors[atom]) and ! is_nil(changeset.action) do
      true ->
        changeset.errors[atom]
        |> Tuple.to_list()
        |> List.first()
      false -> nil
    end
  end
end
