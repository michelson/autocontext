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
    repo = Keyword.get(opts, :repo)
    schema = Keyword.get(opts, :schema)
    changeset_fun = Keyword.get(opts, :changeset)
    before_create = Keyword.get(opts, :before_create, [])
    after_create = Keyword.get(opts, :after_create, [])
    before_save = Keyword.get(opts, :before_save, [])
    after_save = Keyword.get(opts, :after_save, [])
    before_update = Keyword.get(opts, :before_update, [])
    after_update = Keyword.get(opts, :after_update, [])
    before_delete = Keyword.get(opts, :before_delete, [])
    after_delete = Keyword.get(opts, :after_delete, [])

    quote do
      @repo unquote(repo)
      @schema unquote(schema)
      @changeset_fun unquote(changeset_fun)
      @before_create_callbacks unquote(before_create)
      @after_create_callbacks unquote(after_create)
      @before_save_callbacks unquote(before_save)
      @after_save_callbacks unquote(after_save)
      @before_update_callbacks unquote(before_update)
      @after_update_callbacks unquote(after_update)
      @before_delete_callbacks unquote(before_delete)
      @after_delete_callbacks unquote(after_delete)

      def before_save(callback) when is_atom(callback), do: @before_save_callbacks ++ [callback]
      def after_save(callback) when is_atom(callback), do: @after_save_callbacks ++ [callback]

      def before_create(callback) when is_atom(callback),
        do: @before_create_callbacks ++ [callback]

      def after_create(callback) when is_atom(callback), do: @after_create_callbacks ++ [callback]

      def before_update(callback) when is_atom(callback),
        do: @before_update_callbacks ++ [callback]

      def after_update(callback) when is_atom(callback), do: @after_update_callbacks ++ [callback]

      def before_delete(callback) when is_atom(callback),
        do: @before_delete_callbacks ++ [callback]

      def after_delete(callback) when is_atom(callback), do: @after_delete_callbacks ++ [callback]

      def create(params) do
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

      def update(record, params) do
        run_callbacks(:before_update, params)
        run_callbacks(:before_save, record)
        {:ok, record} = @repo.update(record)
        run_callbacks(:after_update, record)
        run_callbacks(:after_save, record)
        {:ok, record}
      end

      def delete(record) do
        run_callbacks(:before_delete, record)
        {:ok, _} = @repo.delete(record)
        run_callbacks(:after_delete, record)
        :ok
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
  end
end
