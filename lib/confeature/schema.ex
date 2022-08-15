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

  def changeset(feature = %__MODULE__{}, params \\ %{}) do
    feature
    |> cast(params, [:name, :attrs])
    |> unique_constraint([:name])
  end
end
