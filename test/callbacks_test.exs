defmodule Autocontext.CallbacksTest do
  use ExUnit.Case, async: true

  import Ecto.Query, only: [from: 2]
  alias Autocontext.Repo
  alias Autocontext.Accounts
  alias Autocontext.User

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Autocontext.Repo)

    # unless tags[:async] do
    Ecto.Adapters.SQL.Sandbox.mode(Autocontext.Repo, {:shared, self()})
    # end
  end

  @valid_attrs %{name: "john_doe", email: "john_doe@example.com", age: "10"}

  test "create/1 successfully creates a User with valid attributes" do
    {:ok, user} = Accounts.create(@valid_attrs)

    assert user.name == "john_doe"
    assert user.email == "john_doe@example.com"
  end

  test "finders" do
    {:ok, user} = Accounts.create(@valid_attrs)

    assert [%Autocontext.User{}] = Accounts.all()
    assert %Autocontext.User{} = Accounts.find_by!(id: user.id)
    assert %Autocontext.User{} = Accounts.find!(user.id)
  end

  test "create/1 returns an error with invalid attributes" do
    {:error, changeset} = Accounts.create(%{})

    assert changeset.valid? == false
  end

  test "before_save callbacks are applied correctly" do
    Accounts.create(@valid_attrs)

    query = from(u in User, where: u.name == "john_doe")
    user = Repo.one(query)

    # Replace this with actual assertions for your before_save callbacks
    assert user.name == "john_doe"
  end

  test "after_save callbacks are applied correctly" do
    {:ok, user} = Accounts.create(@valid_attrs)

    # Replace this with actual assertions for your after_save callbacks
    assert user.name == "john_doe"
  end
end
