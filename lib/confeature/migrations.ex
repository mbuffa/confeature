defmodule Confeature.Migrations do
  use Ecto.Migration

  def up do
    create table(:features, primary_key: false) do
      add :name, :string, primary_key: true, null: false
      add :attrs, :json, default: "{}"

      timestamps()
    end
  end

  def down do
    drop table(:features)
  end
end
