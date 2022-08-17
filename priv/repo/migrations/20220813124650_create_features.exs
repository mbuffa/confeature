defmodule Test.Repo.Migration.CreateFeatures do
  use Ecto.Migration

  def up do
    assert_test_env!()

    Confeature.Migration.up()
    Confeature.Migration.up(table_name: "my_features")
  end

  def down do
    assert_test_env!()

    Confeature.Migration.down()
    Confeature.Migration.down(table_name: "my_features")
  end

  defp assert_test_env!() do
    if Mix.env() != :test, do: raise "Confeature Migration are made for :test env only!"
  end
end
