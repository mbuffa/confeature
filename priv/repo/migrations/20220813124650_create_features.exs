defmodule Test.Repo.Migrations.CreateFeatures do
  use Ecto.Migration

  def up do
    assert_test_env!()

    Confeature.Migrations.up()
  end

  def down do
    assert_test_env!()

    Confeature.Migrations.down()
  end

  defp assert_test_env!() do
    if Mix.env() != :test, do: raise "Confeature migrations are made for :test env only!"
  end
end
