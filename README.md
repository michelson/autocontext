# Autocontext

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `autocontext` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:autocontext, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/autocontext>.


# EctoCallbacks

## Overview

EctoCallbacks is a mix package for Elixir's Ecto library. It introduces ActiveRecord-like callbacks to your Ecto schemas by using Elixir's metaprogramming capabilities. The callbacks run before and after specific events on the data, such as saving changes to a database. 

The package aims to add a standardised way of handling callbacks, allowing developers to implement common functionality (like validation, logging, data transformation, etc.) in a clean and consistent manner across different contexts and schemas.

## Functionality

1. **Callbacks**: The core feature of the package is the ability to define `before_save` and `after_save` callbacks that will be invoked sequentially on an Ecto schema. These callbacks are specified when calling the `use EctoCallbacks` macro in a context module. The callbacks are implemented as functions that take a changeset or a schema and return a transformed changeset or schema.

2. **Creation Functionality**: The package also provides a general `create` function that can be defined for a specific Ecto schema when the `use EctoCallbacks` macro is called. The `create` function includes built-in calls to `before_save` and `after_save` callbacks. This provides a standardised way to create records while leveraging the callback functionality.

## API

### `use EctoCallbacks`

Using the `EctoCallbacks` macro in a module enables the callback functionality for that module. This macro takes the following options:

- `:schema`: An Ecto schema that the callbacks will be applied to.
- `:changeset`: A function that generates a changeset from the provided schema and a map of attributes.
- `:before_save`: A list of callbacks to be applied before saving the changeset.
- `:after_save`: A list of callbacks to be applied after saving the changeset.

Each callback is a function that accepts a changeset or a schema and returns a transformed changeset or schema. These functions are intended to implement any necessary operations or transformations that should occur before or after saving the changeset.

### `create`

This function is automatically defined when the `use EctoCallbacks` macro is used. It takes a map of attributes and uses them to create a new record in the database associated with the provided schema. It automatically calls the `before_save` and `after_save` callbacks.

## Usage Example

```elixir
defmodule MyApp.Accounts do
  use EctoCallbacks,
    schema: MyApp.User,
    changeset: &MyApp.User.changeset/2,
    before_save: [:validate_username, :hash_password],
    after_save: [:send_welcome_email, :track_user_creation]

  defp validate_username(changeset), do: changeset
  defp hash_password(changeset), do: changeset
  defp send_welcome_email(user), do: user
  defp track_user_creation(user), do: user
end
```

## Dependencies

The `EctoCallbacks` package depends on Ecto and should be compatible with Ecto 3.0 and later.

---

With this specification, you should have a clear idea of what you're building. The next step would be to start the implementation, write tests to validate the functionality, and create the package as described in the previous steps.
