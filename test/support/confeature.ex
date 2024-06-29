defmodule Test.Confeature do
  @moduledoc false

  use Confeature,
    ecto_repo: Test.Repo
end

defmodule Test.Confeature.RedisBacked do
  @moduledoc false

  use Confeature,
    ecto_repo: Test.Repo,
    cache: Test.Cache.Redis
end

defmodule Test.Confeature.WithTableName do
  @moduledoc false

  use Confeature,
    ecto_repo: Test.Repo,
    table_name: "my_features"
end
