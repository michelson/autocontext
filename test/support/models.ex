defmodule Autocontext.User do
  use Ecto.Schema
  import Ecto.Changeset

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
  use Autocontext.Finders,
    schema: Autocontext.User,
    repo: Autocontext.Repo

  use Autocontext.EctoCallbacks,
    #  schema: Autocontext.User,
    #  changeset: &Autocontext.User.changeset/2,
    #  repo: Autocontext.Repo,
    #  before_save: [:validate_username, :hash_password],
    #  after_save: [:send_welcome_email, :track_user_creation],
    #  use_transactions: true

    operations: [
      [
        repo: Autocontext.Repo,
        schema: Autocontext.User,
        changeset: &Autocontext.User.changeset/2,
        use_transaction: true,
        before_save: [:validate_username, :hash_password],
        after_save: [:send_welcome_email, :track_user_creation]
      ],
      [
        name: :bar,
        repo: Autocontext.Repo,
        schema: Autocontext.Account,
        changeset: &Autocontext.User.changeset/2,
        use_transaction: false,
        before_save: [:validate_username],
        after_save: [:send_welcome_email]
      ]
    ]

  def validate_username(changeset), do: changeset
  def hash_password(changeset), do: changeset

  def send_welcome_email(user) do
    IO.puts("SEND WELCOME EMAIL!!")
    user
  end

  def track_user_creation(user), do: user
end
