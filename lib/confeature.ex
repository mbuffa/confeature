defmodule Confeature do
  @moduledoc """
  Defines a macro for implementing your own feature settings store on top of
  Ecto and the cache store of your choice.

  You can simply declare your module like this:

      defmodule MyApp.Confeature do
        use Confeature,
            ecto_repo: MyApp.Repo,
            cache: MyApp.Cache.Feature
      end

  Please refer to the `Confeature.Cache` module doc for detailed instructions
  on how to implement your cache.

  The two parameters of this macro are required.

  The functions docs below will assume you have the following feature modules
  declared, as references:

      defmodule MyApp.Features.UsageAlert do
        defstruct [:threshold]

        @type t :: %__MODULE__{
          threshold: float()
        }
      end

      defmodule MyApp.Features.HiddenPixel do
        defstruct [:enabled, :x, :y]

        @type t :: %__MODULE__{
          enabled: boolean(),
          x: integer(),
          y: integer()
        }
      end

  """

  @doc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Confeature

      @repo Keyword.fetch!(opts, :ecto_repo)
      @cache Keyword.fetch!(opts, :cache)

      def __repo__, do: @repo
      def __cache__, do: @cache

      import Ecto.{
        Changeset,
        Query
      }

      alias Confeature.{
        Schema,
        Type
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

      def set!(%{__struct__: name} = feature_struct) do
        attrs =
          feature_struct
          |> Map.from_struct()

        # |> Map.drop([:name]) # FIXME: Reject reserved keyword

        changeset =
          case get_record(name) do
            %Schema{} = feature ->
              Schema.changeset(feature, %{attrs: attrs})

            nil ->
              Schema.changeset(%Schema{name: name}, %{attrs: attrs})
          end

        {:ok, result} =
          apply(__repo__(), :insert_or_update, [
            changeset,
            [on_conflict: :replace_all, conflict_target: :name]
          ])

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

      def delete!(name) do
        feature =
          name
          |> get_record()

        {:ok, _result} = apply(__repo__(), :delete, [feature])
        {:ok, _result} = apply(__cache__(), :delete, [name])
      end
    end
  end

  @doc """
  Returns a feature struct based on the module name.

      MyApp.Confeature.get(MyApp.Features.UsageAlert)
      # If you never set it:
      => nil

      # After setting it:
      => %MyApp.Features.UsageAlert{threshold: 4.5}
  """
  @callback get(name :: atom()) :: struct() | nil

  @doc """
  Writes new settings using a feature struct. It'll write to the database
  and invalidate cache right after.

  This function allows incremental updates; parameters you don't provide
  won't get erased.

      MyApp.Confeature.set!(%MyApp.Features.HiddenPixel{x: 43, y: 219})
      => {:ok, *your_updated_struct*}
  """
  @callback set!(struct :: struct()) :: {:ok, struct()}

  @doc """
  Returns true if your feature is enabled. This is a helper function, and
  it requires you to declare the enabled boolean field on the feature
  struct.

      MyApp.Confeature.enabled?(MyApp.Features.UsageAlert)
      => *will throw an error*

      MyApp.Confeature.enabled?(MyApp.Features.HiddenPixel)
      => false
  """
  @callback enabled?(name :: atom()) :: boolean()

  @doc """
  Enables a feature. This is a helper function, and it requires you to
  declare the enabled boolean field on the feature struct.

      MyApp.Confeature.enable!(MyApp.Features.UsageAlert)
      => *will throw an error*

      MyApp.Confeature.enable!(MyApp.Features.HiddenPixel)
      => {:ok, *your_updated_struct*}
  """
  @callback enable!(name :: atom()) :: {:ok, struct()}

  @doc """
  Disables a feature. This is a helper function, and it requires you to
  declare the enabled boolean field on the feature struct.

      MyApp.Confeature.disable!(MyApp.Features.UsageAlert)
      => *will throw an error*

      MyApp.Confeature.disable!(MyApp.Features.HiddenPixel)
      => {:ok, *your_updated_struct*}
  """
  @callback disable!(name :: atom()) :: {:ok, struct()}

  @doc """
  Deletes the feature row from your database and invalidates the cache.

  You may want to call this function once you're completely done with a
  feature (eg. in a post-release Ecto migration).
  """
  @callback delete!(name :: atom()) :: {:ok, any()}
end
