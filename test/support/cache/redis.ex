defmodule Test.Cache.Redis do
  @behaviour Confeature.Cache

  # In seconds
  @ttl 600

  @impl true
  def get(name) do
    {:ok, [result]} = Redix.pipeline(Test.Redix, [["GET", name]])

    result |> deserialize()
  end

  @impl true
  def set(name, data) do
    data = serialize(data)

    case Redix.pipeline(Test.Redix, [["SET", name, data, "EX", @ttl]]) do
      {:ok, ["OK"]} ->
        {:ok, data}

      reason ->
        {:error, reason}
    end
  end

  @impl true
  def delete(name) do
    {:ok, [_result]} = Redix.pipeline(Test.Redix, [["DEL", name]])
  end

  defp serialize(nil), do: nil

  defp serialize(%Confeature.Schema{} = data) do
    {:ok, serialized} =
      data
      |> Map.from_struct()
      |> Map.drop([:__meta__])
      |> Jason.encode()

    serialized
  end

  defp deserialize(nil), do: nil

  defp deserialize(data) do
    {:ok,
     %{
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
