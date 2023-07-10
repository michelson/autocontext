defmodule Autocontext.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :age, :integer

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
