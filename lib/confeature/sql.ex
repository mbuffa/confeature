defmodule Confeature.SQL do
  @moduledoc """
  Internal module to perform SQL operations.
  """

  import Ecto.Query

  alias Confeature.{
    Schema,
    Type
  }

  defp maybe_override_query_source(query, nil), do: query

  defp maybe_override_query_source(query, table_name) when is_binary(table_name) do
    %Ecto.Query.FromExpr{
      source: {"features", Schema}
    } = from = query.from

    %{query | from: %{from | source: {table_name, Schema}}}
  end

  defp maybe_override_changeset_source(changeset, nil), do: changeset

  defp maybe_override_changeset_source(changeset, table_name) do
    %{changeset | data: Ecto.put_meta(changeset.data, source: table_name)}
  end

  @spec get(parent :: atom(), name :: atom()) :: Schema.t() | nil
  def get(parent, name) when is_atom(parent) and is_atom(name) do
    table_name = apply(parent, :__table_name__, [])

    query =
      where(Schema, [f], f.name == ^name)
      |> maybe_override_query_source(table_name)

    apply(parent, :__repo__, [])
    |> apply(:one, [query])
  end

  @spec upsert(parent :: atom(), feature :: struct()) :: {:ok, struct()}
  def upsert(parent, %{__struct__: name} = feature) do
    table_name = apply(parent, :__table_name__, [])
    attrs = Map.from_struct(feature)

    changeset =
      case get(parent, name) do
        %Schema{} = record ->
          Schema.changeset(record, %{attrs: attrs})

        nil ->
          Schema.changeset(%Schema{}, %{name: name, attrs: attrs})
      end
      |> maybe_override_changeset_source(table_name)

    apply(parent, :__repo__, [])
    |> apply(:insert_or_update, [
      changeset,
      [on_conflict: :replace_all, conflict_target: :name]
    ])
  end

  @spec delete(parent :: atom(), name :: atom()) ::
          {:ok, struct()} | {:error, changeset :: term()}
  def delete(parent, name) do
    %Schema{} = feature = get(parent, name)

    apply(parent, :__repo__, [])
    |> apply(:delete, [feature])
  end

  @spec enable(parent :: atom(), name :: atom()) :: {:ok, struct()}
  def enable(parent, name) when is_atom(name) do
    case get(parent, name) do
      %Schema{} = record ->
        {:ok, feature} = Type.load(record)
        upsert(parent, %{feature | enabled: true})

      nil ->
        {:error, :not_found}
    end
  end

  @spec disable(parent :: atom(), name :: atom()) :: {:ok, struct()}
  def disable(parent, name) when is_atom(name) do
    case get(parent, name) do
      %Schema{} = record ->
        {:ok, feature} = Type.load(record)
        upsert(parent, %{feature | enabled: false})

      nil ->
        {:error, :not_found}
    end
  end
end
