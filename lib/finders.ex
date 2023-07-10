defmodule Autocontext.Finders do
  defmacro __using__(opts) do
    repo = Keyword.get(opts, :repo)
    schema = Keyword.get(opts, :schema)

    quote do
      import Ecto.Query, warn: false
      @repo unquote(repo)
      @schema unquote(schema)

      def all do
        @repo.all(@schema)
      end

      # Accounts.find!(39)
      def find!(id), do: @repo.get!(@schema, id)

      # Accounts.find_by!(id: 39)
      def find_by!(conds), do: @repo.get_by!(@schema, conds)

      def change(
            struct,
            attrs \\ %{}
          ) do
        @schema.changeset(struct, attrs)
      end

      defoverridable all: 0, find!: 1, change: 1
    end
  end
end
