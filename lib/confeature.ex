defmodule Confeature do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @repo Keyword.fetch!(opts, :ecto_repo)

      def __repo__, do: @repo

      import Ecto.{
        Changeset, Query
      }

      alias Confeature.{
        Schema, Type
      }

      defp get_record(name) when is_atom(name) do
        query = where(Schema, [f], f.name == ^name)
        apply(__repo__(), :one, [query])
      end



      def get(name) when is_atom(name) do
        {:ok, feature} =
          name
          |> get_record()
          |> Type.load()
        feature
      end

      def set!(%{__struct__: name} = feature_struct) do
        attrs =
          feature_struct
          |> Map.from_struct()
          # |> Map.drop([:name]) # FIXME: Assert reserved keyword

        case get_record(name) do
          %Schema{} = feature ->
            changeset = Schema.changeset(feature, %{attrs: attrs})
            {:ok, _result} = apply(__repo__(), :update, [changeset])

          nil ->
            changeset = Schema.changeset(%Schema{name: name}, %{attrs: attrs})
            {:ok, _result} = apply(__repo__(), :insert, [changeset])
        end
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
