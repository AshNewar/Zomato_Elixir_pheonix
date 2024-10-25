defmodule Zomato.Repo.Migrations.CreatePhotos do
  use Ecto.Migration

  def change do
    create table(:photos) do
      add :url, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :restaurant_id, references(:restraurents, on_delete: :nothing)
      add :user_done, :boolean, default: false

      timestamps(type: :utc_datetime)
    end

    create index(:photos, [:user_id])
    create index(:photos, [:restaurant_id])
  end
end
