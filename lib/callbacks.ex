defmodule Autocontext.EctoCallbacks do
  defmacro __using__(opts) do
    operations = Keyword.get(opts, :operations, [])

    for operation <- operations do
      operation_name = Keyword.get(operation, :name, nil)
      operation_name = if operation_name, do: "#{operation_name}_", else: ""

      quote do
        def unquote(:"#{operation_name}create")(params) do
          repo = unquote(operation[:repo])
          schema = unquote(operation[:schema])
          changeset_fun = unquote(operation[:changeset])
          use_transaction = unquote(operation[:use_transaction])
          before_create = unquote(operation[:before_create])
          after_create = unquote(operation[:after_create])
          before_save = unquote(operation[:before_save])
          after_save = unquote(operation[:after_save])

          changeset = changeset_fun.(Kernel.struct(schema), params)

          operation_func = fn ->
            run_callbacks(before_save, changeset)
            run_callbacks(before_create, changeset)

            case repo.insert(changeset) do
              {:ok, record} ->
                run_callbacks(after_save, record)
                run_callbacks(after_create, changeset)

                {:ok, record}

              error ->
                error
            end
          end

          run_with_or_without_transaction(operation_func, use_transaction, repo)
        end

        def unquote(:"#{operation_name}update")(record, params) do
          repo = unquote(operation[:repo])
          use_transaction = unquote(operation[:use_transaction])
          before_update = unquote(operation[:before_update])
          after_update = unquote(operation[:after_update])
          before_save = unquote(operation[:before_save])
          after_save = unquote(operation[:after_save])

          operation_func = fn ->
            run_callbacks(before_update, params)
            run_callbacks(before_save, record)
            {:ok, record} = repo.update(record)
            run_callbacks(after_update, record)
            run_callbacks(after_save, record)

            {:ok, record}
          end

          run_with_or_without_transaction(operation_func, use_transaction, repo)
        end

        def unquote(:"#{operation_name}delete")(record) do
          repo = unquote(operation[:repo])
          use_transaction = unquote(operation[:use_transaction])
          before_delete = unquote(operation[:before_delete])
          after_delete = unquote(operation[:after_delete])

          operation_func = fn ->
            run_callbacks(before_delete, record)
            {:ok, _} = repo.delete(record)
            run_callbacks(after_delete, record)

            {:ok, record}
          end

          run_with_or_without_transaction(operation_func, use_transaction, repo)
        end

        defp run_with_or_without_transaction(operation_func, use_transaction, repo) do
          if use_transaction do
            case Ecto.Multi.new()
                 |> Ecto.Multi.run(:operation, fn _repo, _changes -> operation_func.() end)
                 |> repo.transaction() do
              {:error, %{operation: result}} ->
                {:error, result}

              {:ok, %{operation: result}} ->
                {:ok, result}

              {:error, :operation, result, _} ->
                {:error, result}

              # or raise?
              a ->
                IO.puts("nothing to do on transaction result")
                IO.inspect(a)
                nil
            end
          else
            operation_func.()
          end
        end

        defp run_callbacks(nil, _params), do: :ok

        defp run_callbacks(callbacks, params) when is_list(callbacks) do
          Enum.each(callbacks, fn callback ->
            apply(__MODULE__, callback, [params])
          end)
        end
      end
    end
  end
end
