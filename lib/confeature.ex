defmodule Confeature do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @repo Keyword.fetch!(opts, :ecto_repo)
      @cache Keyword.fetch!(opts, :cache)

      def __repo__, do: @repo
      def __cache__, do: @cache

      import Ecto.{
        Changeset, Query
      }

      alias Confeature.{
        Schema, Type
      }

      defp get_record(name) when is_atom(name) do
        case apply(__cache__(), :get, [name]) do
          %Schema{} = feature ->
            feature

          nil ->
            query = where(Schema, [f], f.name == ^name)
            result = apply(__repo__(), :one, [query])
            unless is_nil(result) do
              {:ok, _result} = apply(__cache__(), :set, [name, result])
            end
            result
        end
      end



      def get(name) when is_atom(name) do
        {:ok, feature} =
          name
          |> get_record()
          |> Type.load()
        feature
      end

      # TODO: Check why insert_or_update doesn't detect the right action to make with Redis cache.
      # Also, it's probably rewritting `inserted_at` timestamp at each update.
      def set!(%{__struct__: name} = feature_struct) do
        attrs =
          feature_struct
          |> Map.from_struct()
          # |> Map.drop([:name]) # FIXME: Assert reserved keyword

        changeset = case get_record(name) do
          %Schema{} = feature ->
            Schema.changeset(feature, %{attrs: attrs})

          nil ->
            Schema.changeset(%Schema{name: name}, %{attrs: attrs})
        end

        {:ok, result} = apply(__repo__(), :insert_or_update, [changeset, [on_conflict: :replace_all, conflict_target: :name]])
        {:ok, _result} = apply(__cache__(), :set, [name, result])
        {:ok, result}
      end

      def enabled?(name) do
        name
        |> get()
        |> Map.fetch!(:enabled)
      end

      def enable!(name) do
        name
        |> get()
        |> Map.put(:enabled, true)
        |> set!()
      end

      def disable!(name) do
        name
        |> get()
        |> Map.put(:enabled, false)
        |> set!()
      end
    end
  end
end
