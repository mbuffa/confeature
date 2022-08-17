defmodule Test.Confeature do
  use Confeature,
    ecto_repo: Test.Repo
end

defmodule Test.Confeature.RedisBacked do
  use Confeature,
    ecto_repo: Test.Repo,
    cache: Test.Cache.Redis
end
