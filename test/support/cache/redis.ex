defmodule Test.Cache.Redis do
  @ttl 600 # In seconds

  def get(name) do
    {:ok, [result]} = Redix.pipeline(Test.Redix, [["GET", name]])
    result |> deserialize()
  end

  def set(name, data) do
    data = serialize(data)
    {:ok, ["OK"]} = Redix.pipeline(Test.Redix, [["SET", name, data, "EX", @ttl]])
    {:ok, data}
  end

  defp serialize(nil), do: nil
  defp serialize(data) do
    {:ok, serialized} =
      data
      |> Map.from_struct()
      |> Map.drop([:__meta__])
      |> Jason.encode()
    serialized
  end

  defp deserialize(nil), do: nil
  defp deserialize(data) do
    {:ok, %{
      name: name,
      attrs: attrs,
      inserted_at: inserted_at,
      updated_at: updated_at
    }} =
      data
      |> Jason.decode(keys: :atoms)

    %Confeature.Schema{
      name: name,
      attrs: attrs,
      inserted_at: inserted_at |> NaiveDateTime.from_iso8601!(),
      updated_at: updated_at |> NaiveDateTime.from_iso8601!()
    }
  end
end
