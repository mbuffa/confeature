defmodule Confeature.Schema do
  @moduledoc """
  Defines an internal Ecto schema and changeset used to store Features.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Confeature.Type, as: CustomType

  @primary_key false

  @type t() :: %__MODULE__{
          name: binary(),
          attrs: map(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "features" do
    field(:name, CustomType, primary_key: true)
    field(:attrs, :map)
    timestamps()
  end

  def changeset(%__MODULE__{} = feature, params \\ %{}) do
    new_attrs =
      params
      |> Map.fetch!(:attrs)
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Enum.map(fn
        {k, v} when is_atom(k) -> {Atom.to_string(k), v}
        {k, v} -> {k, v}
      end)
      |> Enum.into(%{})

    new_attrs =
      Map.fetch!(feature, :attrs)
      |> replace_nil_with_map()
      |> Map.merge(new_attrs)

    params =
      params
      |> Map.put(:attrs, new_attrs)

    feature
    |> cast(params, [:name, :attrs])
    |> unique_constraint([:name])
  end

  defp replace_nil_with_map(%{} = map), do: map
  defp replace_nil_with_map(nil), do: %{}
end
