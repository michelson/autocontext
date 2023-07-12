[![Elixir CI](https://github.com/michelson/autocontext/actions/workflows/test.yml/badge.svg)](https://github.com/michelson/autocontext/actions/workflows/test.yml)

# Autocontext

`Autocontext` is an Elixir library that provides ActiveRecord-like callbacks for Ecto, Elixir's database wrapper. This allows you to specify functions to be executed before and after certain operations (`insert`, `update`, `delete`), enhancing control over these operations and maintaining a clean and expressive code base.

## Features

- `before_save`, `after_save`, `before_create`, `after_create`, `before_update`, `after_update`, `before_delete`, `after_delete` callbacks.
- Fully customizable with the ability to specify your own callback functions.
- Supports the Repo option, which allows you to use different Repo configurations.
- Works seamlessly with Ecto's changesets and other features.
- Multiple changesets and multiple schemas are allowed.

---

## Installation

Add the `autocontext_ecto_callbacks` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:autocontext, "~> 0.1.0"}
  ]
end
```

## Usage

Define a context module for your Ecto operations and `use Autocontext.EctoCallbacks`:

```elixir
defmodule MyApp.Accounts do
  use Autocontext.EctoCallbacks, operations: [
    [
      name: :user,
      repo: MyApp.Repo,
      schema: MyApp.User,
      changeset: &MyApp.User.changeset/2,
      use_transaction: true,
      before_save: [:validate_username, :hash_password],
      after_save: [:send_welcome_email, :track_user_creation]
    ],
    [
      name: :admin,
      repo: MyApp.Repo,
      schema: MyApp.Admin,
      changeset: &MyApp.Admin.changeset/2,
      use_transaction: false,
      before_create: [:check_admin_limit],
      after_create: [:send_admin_email]
    ]
  ]

  # Callback implementations...
end
```

In the above configuration:

- `:name` defines a unique name for the operation. This name is used to generate the actual Ecto operation functions: `user_create`, `user_update`, `user_delete`, `admin_create`, `admin_update`, `admin_delete`. If the option is nil then a `create`, `delete`, and `update` methods will be created for the schema.
- `:repo` is the Ecto repository to interact with.
- `:schema` is the Ecto schema for the data structure.
- `:changeset` is the changeset function used for the data validation and transformations.
- `:use_transaction` is a boolean flag to indicate whether to perform the operations within a database transaction or not.
- The remaining keys (`:before_save`, `:after_save`, `:before_create`, `:after_create`, etc.) define the callback functions to be called before or after the actual Ecto operations. These callbacks must be implemented within the same module and they should return the changeset or record they receive.

Then, you can call the functions as follows:

```elixir
params = %{name: "john_doe", email: "john_doe@example.com", age: 10}

case MyApp.Accounts.user_create(params) do
  {:ok, user} ->
    IO.puts("User created successfully.")

  {:error, changeset} ->
    IO.puts("Failed to create user.")
end
```

---

# Finders

Finders gives an easy way to access records, like find, find_by and all

```elixir
defmodule Autocontext.Accounts do
  use Autocontext.Finders,
    schema: User,
    repo: Repo
end
```

```elixir
Accounts.find!(1)
Accounts.find_by!(name: "mike")
Accounts.all
```

## Installation

Add `autocontext` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:autocontext, "~> 0.1.0"}
  ]
end
```

Then, update your dependencies:

```
$ mix deps.get
```