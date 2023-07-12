defmodule Autocontext.CallbackBehaviour do
  @callback before_create(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  @callback after_create(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  @callback before_save(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  @callback after_save(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  @callback before_update(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  @callback after_update(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  @callback before_delete(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  @callback after_delete(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  @callback validate_username(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  @callback hash_password(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  @callback foo_create(Ecto.Changeset.t()) :: Ecto.Changeset.t()
end

defmodule Autocontext.User do
  use Ecto.Schema
  import Ecto.Changeset

  if Mix.env() == :test do
    def callback_module, do: Autocontext.CallbackMock
  else
    def callback_module, do: __MODULE__
  end

  schema "users" do
    field(:email, :string)
    field(:name, :string)
    field(:age, :integer)

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :age])
    |> validate_required([:name, :email, :age])
    |> unique_constraint(:email)
  end
end

defmodule Autocontext.Accounts do
  @behaviour Autocontext.CallbackBehaviour

  use Autocontext.Finders,
    schema: Autocontext.User,
    repo: Autocontext.Repo

  use Autocontext.EctoCallbacks,
    operations: [
      [
        repo: Autocontext.Repo,
        schema: Autocontext.User,
        changeset: &Autocontext.User.changeset/2,
        use_transaction: false,
        before_save: [:validate_username, :hash_password],
        after_save: [:send_welcome_email, :track_user_creation]
      ],
      [
        name: :foo,
        repo: Autocontext.Repo,
        schema: Autocontext.User,
        changeset: &Autocontext.User.changeset/2,
        use_transaction: true,
        before_save: [:validate_username],
        after_save: [:send_welcome_email]
      ]
    ]

  def validate_username(changeset) do
    IO.puts("VALIDATE USERNAME")
    changeset
  end

  def hash_password(changeset) do
    IO.puts("HASH PASSWORD")
    changeset
  end

  def send_welcome_email(user) do
    IO.puts("SEND WELCOME EMAIL!!")
    user
  end

  def track_user_creation(user) do
    IO.puts("TRACK USER CREATION")
    user
  end
end
