# Confeature

`Confeature` is a generic and simple Elixir library to handle your application-wide feature settings, storing them with Ecto and providing a cache interface.

Please note that this is a very early development, and that `Confeature` hasn't been tested a lot in production yet.

Also, if you're looking for feature flags that you may apply on groups or actors, you should definitely use `:fun_with_flags` instead.

The scope of `Confeature` is primarily set on:
* Allowing you to change your application settings dynamically,
* Setting any value at runtime,
* Type-checking updates with structs and specs.

## Documentation

Documentation is available on [https://hexdocs.pm/confeature](https://hexdocs.pm/confeature).

## Installation

Add `confeature` to your dependencies:
```elixir
def deps do
  [
    {:confeature, "~> 0.1.1"}
  ]
end
```

## Usage

Start by creating Confeature table:
```sh
mix ecto.gen.migration create_confeature_table
```

And use Confeature provided migration:
```elixir
defmodule YourEctoMigration do
  def up do
    Confeature.Migration.up()
    # or optionally:
    Confeature.Migration.up(table_name: "my_features")
  end

  def down do
    Confeature.Migration.down()
    # or optionally:
    Confeature.Migration.down(table_name: "my_features")
  end
end
```

Declare your Confeature interface
```elixir
defmodule MyApp.Confeature do
  use Confeature,
    ecto_repo: MyApp.Repo,
    table_name: "my_features", # Optional
    cache: MyApp.Cache.Feature # Optional
end
```
You can check the documentation for implementing a cache store that'll avoid querying your database on each call.

Then, declare a feature, like this:
```elixir
defmodule MyApp.Features.Throttling do
  defstruct [:identifier, :threshold]

  @type t :: %__MODULE__{
    identifier: string(),
    threshold: integer()
  }
end
```

Let's say that you'd want to initialize it in an Ecto migration:
```sh
mix ecto.gen.migration init_throttling_settings
```

```elixir
defmodule YourMigration do
  def up do
    MyApp.Confeature.set(%MyApp.Features.Throttling{
      identifier: "token",
      threshold: 500 # 500 requests
    })
  end

  def down do
    MyApp.Confeature.delete!(MyApp.Features.Throttling)
  end
end
```

You can then reference it in your code:
```elixir
# Retrieve settings
iex> MyApp.Confeature.get(MyApp.Features.Throttling)
%MyApp.Features.Throttling{identifier: "token", threshold: 500}

iex> MyApp.Confeature.set(%MyApp.Features.Throttlin{identifier: "token", threshold: 1000})
%MyApp.Features.Throttling{identifier: "token", threshold: 1000}
```

Confeature upserts one row per feature in your RDBMS, using a json field to store attributes.

You can also declare a `:enabled` attribute, so your feature can be enabled and disabled at runtime:
```elixir
defmodule MyApp.Features.Throttling do
  defstruct [:enabled, :identifier, :threshold]

  @type t :: %__MODULE__{
    enabled: boolean(),
    identifier: string(),
    threshold: integer()
  }
end

MyApp.Confeature.enabled?(MyApp.Features.Throttling) 
MyApp.Confeature.enable(MyApp.Features.Throttling) 
MyApp.Confeature.disable(MyApp.Features.Throttling) 
```
