defmodule Confeature.Schema do
  use Ecto.Schema
  import Ecto.Changeset

  alias Confeature.Type, as: CustomType

  @primary_key false

  schema "features" do
    field :name, CustomType, primary_key: true
    field :attrs, :map
    timestamps()
  end

  def changeset(%__MODULE__{} = feature, params \\ %{}) do
    feature
    |> cast(params, [:name, :attrs])
    |> unique_constraint([:name])
  end

  def changeset_from_struct(feature_struct) do
    %__MODULE__{
      name: feature_struct.__struct__,
      attrs: Map.from_struct(feature_struct)
    }
    |> cast(%{}, [])
    |> unique_constraint([:name])
  end
end
