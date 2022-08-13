defmodule Test.Repo.Migrations.CreateFeatures do
  use Ecto.Migration

  def change do
    assert_test_env!()

    create table(:features, primary_key: false) do
      add :name, :string, primary_key: true, null: false
      add :attrs, :json, default: "{}"

      timestamps()
    end
  end

  defp assert_test_env!() do
    if Mix.env() != :test, do: raise "Confeature migrations are made for :test env only!"
  end
end
