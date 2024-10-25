defmodule Zomato.Repo.Migrations.CreateFollowers do
  use Ecto.Migration

  def change do
    create table(:followers) do
      add :follower_id, references(:users, on_delete: :nothing)
      add :followed_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:followers, [:follower_id])
    create index(:followers, [:followed_id])
  end
end
