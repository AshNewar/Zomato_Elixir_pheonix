defmodule Zomato.Repo.Migrations.CreateRestraurentsAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:restraurents) do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :utc_datetime
      add :name, :string
      add :phone, :string
      add :address, :string
      add :profile_pic, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:restraurents, [:email])

    create table(:restraurents_tokens) do
      add :restraurent_id, references(:restraurents, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:restraurents_tokens, [:restraurent_id])
    create unique_index(:restraurents_tokens, [:context, :token])
  end
end
