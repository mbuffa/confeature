defmodule Confeature.Type do
  use Ecto.Type

  def type, do: :string

  def cast(string) when is_binary(string), do: {:ok, String.to_existing_atom(string)}
  def cast(atom) when is_atom(atom) do
    {:ok ,atom}
  end
  def cast(%{name: name, attrs: attrs}) do
    {:ok, module} = cast(name)
    attrs =
      attrs
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
      |> Enum.into(%{})

    {:ok, struct!(module, attrs)}
  end

  def load(name) do
    cast(name)
  end

  def dump(module) when is_atom(module), do: {:ok, Atom.to_string(module)}
  def dump(module_str) when is_binary(module_str), do: {:ok, module_str}
  def dump(_), do: :error
end
