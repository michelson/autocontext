# ExUnit.start()

Mix.Task.run("ecto.create", ~w(-r Autocontext.Repo))
Mix.Task.run("ecto.migrate", ~w(-r Autocontext.Repo))

Autocontext.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Autocontext.Repo, :manual)

Mox.defmock(Autocontext.CallbackMock, for: Autocontext.CallbackBehaviour)

ExUnit.start()
