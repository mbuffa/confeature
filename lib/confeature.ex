defmodule Confeature do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @repo Keyword.fetch!(opts, :ecto_repo)
      def __repo__ do
        @repo
      end

      import Ecto.{
        Changeset, Query
      }

      alias Confeature.{
        Schema, Type
      }

      defp get_record(name) when is_atom(name) do
        query = where(Schema, [f], f.name == ^name)
        %Schema{} = feature = apply(__repo__(), :one!, [query])
      end

      def get(name) when is_atom(name) do
        {:ok, feature} =
          name
          |> get_record()
          |> Type.load()
        feature
      end

      def set!(feature_struct) when is_struct(feature_struct) do
        changeset = Schema.changeset_from_struct(feature_struct)
        {:ok, _result} = apply(__repo__(), :insert_or_update, [changeset])
      end

      def enabled?(feature_name) do
        feature_name
        |> get()
        |> Map.fetch!(:enabled)
      end

      def enable!(feature_name) do
        feature = get_record(feature_name)

        changeset =
          feature
          |> Schema.changeset(%{attrs: Map.update!(feature.attrs, "enabled", fn _ -> true end)})

        {:ok, _result} = apply(__repo__(), :update, [changeset])
      end

      def disable!(feature_name) do
        feature = get_record(feature_name)

        changeset =
          feature
          |> Schema.changeset(%{attrs: Map.update!(feature.attrs, "enabled", fn _ -> false end)})

        {:ok, _result} = apply(__repo__(), :update, [changeset])
      end
    end
  end
end
