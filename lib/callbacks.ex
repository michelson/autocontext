# defmodule MyApp.Accounts do
#   use MyApp.EctoCallbacks,
#     schema: MyApp.User,
#     changeset: &MyApp.User.changeset/2,
#     before_save: [:validate_username, :hash_password],
#     after_save: [:send_welcome_email, :track_user_creation]
#
#   defp validate_username(changeset) do
#     # Do validation on username...
#     changeset
#   end
#
#   defp hash_password(changeset) do
#     # Hash the password...
#     changeset
#   end
#
#   defp send_welcome_email(user) do
#     # Send a welcome email...
#     user
#   end
#
#   defp track_user_creation(user) do
#     # Track user creation in some analytics system...
#     user
#   end
# end

defmodule Autocontext.EctoCallbacks do
  defmacro __using__(opts) do
    operations = Keyword.get(opts, :operations, [])

    operations
    |> Enum.map(fn operation ->
      operation_name = Keyword.get(operation, :name)
      operation_name = if operation_name, do: "#{operation_name}_", else: ""
      repo = Keyword.get(operation, :repo)
      schema = Keyword.get(operation, :schema)
      changeset_fun = Keyword.get(operation, :changeset)
      use_transaction = Keyword.get(operation, :use_transaction, false)
      before_create = Keyword.get(operation, :before_create, [])
      after_create = Keyword.get(operation, :after_create, [])
      before_save = Keyword.get(operation, :before_save, [])
      after_save = Keyword.get(operation, :after_save, [])
      before_update = Keyword.get(operation, :before_update, [])
      after_update = Keyword.get(operation, :after_update, [])
      before_delete = Keyword.get(operation, :before_delete, [])
      after_delete = Keyword.get(operation, :after_delete, [])

      quote do
        @repo unquote(repo)
        @schema unquote(schema)
        @changeset_fun unquote(changeset_fun)
        @use_transaction unquote(use_transaction)
        @before_create_callbacks unquote(before_create)
        @after_create_callbacks unquote(after_create)
        @before_save_callbacks unquote(before_save)
        @after_save_callbacks unquote(after_save)
        @before_update_callbacks unquote(before_update)
        @after_update_callbacks unquote(after_update)
        @before_delete_callbacks unquote(before_delete)
        @after_delete_callbacks unquote(after_delete)

        def unquote(:"#{operation_name}create")(params) do
          operation = fn ->
            changeset = @changeset_fun.(Kernel.struct(@schema), params)
            run_callbacks(:before_save, changeset)
            run_callbacks(:before_create, changeset)

            case @repo.insert(changeset) do
              {:ok, record} ->
                run_callbacks(:after_save, record)
                run_callbacks(:after_create, changeset)
                {:ok, record}

              error ->
                error
            end
          end

          run_with_or_without_transaction(operation)
        end

        def unquote(:"#{operation_name}update")(record, params) do
          operation = fn ->
            run_callbacks(:before_update, params)
            run_callbacks(:before_save, record)
            {:ok, record} = @repo.update(record)
            run_callbacks(:after_update, record)
            run_callbacks(:after_save, record)
            {:ok, record}
          end

          run_with_or_without_transaction(operation)
        end

        def unquote(:"#{operation_name}delete")(record) do
          operation = fn ->
            run_callbacks(:before_delete, record)
            {:ok, _} = @repo.delete(record)
            run_callbacks(:after_delete, record)
            :ok
          end

          run_with_or_without_transaction(operation)
        end

        defp run_with_or_without_transaction(operation) do
          if @use_transaction do
            @repo.transaction(operation)
          else
            operation.()
          end
        end

        defp run_callbacks(callback_type, params) do
          callbacks =
            case callback_type do
              :before_save -> @before_save_callbacks
              :after_save -> @after_save_callbacks
              :before_create -> @before_create_callbacks
              :after_create -> @after_create_callbacks
              :before_update -> @before_update_callbacks
              :after_update -> @after_update_callbacks
              :before_delete -> @before_delete_callbacks
              :after_delete -> @after_delete_callbacks
            end

          Enum.each(callbacks, fn callback ->
            apply(__MODULE__, callback, [params])
          end)
        end
      end
    end)
  end
end
