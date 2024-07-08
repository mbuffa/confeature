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

  Providing an ecto_repo is mandatory, but by default, Confeature will use a
  placeholder cache module. Please refer to the `Confeature.Cache` module doc for detailed instructions
  on how to implement your cache.

  The functions docs below assume that you have the following feature modules
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
      @cache Keyword.get(opts, :cache, Confeature.Cache.Default)
      @table_name Keyword.get(opts, :table_name)

      def __repo__, do: @repo
      def __cache__, do: @cache
      def __table_name__, do: @table_name

      import Ecto.{
        Changeset,
        Query
      }

      alias Confeature.{
        Schema,
        Type,
        SQL
      }

      def get(name) when is_atom(name) do
        case apply(__cache__(), :get, [name]) do
          %Schema{} = feature ->
            {:ok, feature} = feature |> Type.load()

            feature

          nil ->
            case SQL.get(__MODULE__, name) do
              nil ->
                nil

              %Confeature.Schema{} = record ->
                {:ok, _result} = apply(__cache__(), :set, [name, record])
                {:ok, feature} = record |> Type.load()
                feature
            end
        end
      end

      def set(%{__struct__: name} = feature_struct) do
        {:ok, result} = SQL.upsert(__MODULE__, feature_struct)
        {:ok, _result} = apply(__cache__(), :set, [name, result])

        {:ok, _} = result |> Type.load()
      end

      def delete(name) do
        feature = SQL.get(__MODULE__, name)

        {:ok, _result} = apply(__repo__(), :delete, [feature])
        {:ok, _result} = apply(__cache__(), :delete, [name])
      end

      def enabled?(name) do
        name
        |> get()
        |> Map.fetch!(:enabled)
      end

      def enable(name) do
        name
        |> get()
        |> Map.put(:enabled, true)
        |> set()
      end

      def disable(name) do
        name
        |> get()
        |> Map.put(:enabled, false)
        |> set()
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

      MyApp.Confeature.set(%MyApp.Features.HiddenPixel{x: 43, y: 219})
      => {:ok, *your_updated_struct*}
  """
  @callback set(struct :: struct()) :: {:ok, struct()}

  @doc """
  Deletes the feature row from your database and invalidates the cache.

  You may want to call this function once you're completely done with a
  feature (eg. in a post-release Ecto migration).
  """
  @callback delete(name :: atom()) :: {:ok, any()}

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

      MyApp.Confeature.enable(MyApp.Features.UsageAlert)
      => *will throw an error*

      MyApp.Confeature.enable(MyApp.Features.HiddenPixel)
      => {:ok, *your_updated_struct*}
  """
  @callback enable(name :: atom()) :: {:ok, struct()}

  @doc """
  Disables a feature. This is a helper function, and it requires you to
  declare the enabled boolean field on the feature struct.

      MyApp.Confeature.disable(MyApp.Features.UsageAlert)
      => *will throw an error*

      MyApp.Confeature.disable(MyApp.Features.HiddenPixel)
      => {:ok, *your_updated_struct*}
  """
  @callback disable(name :: atom()) :: {:ok, struct()}
end
