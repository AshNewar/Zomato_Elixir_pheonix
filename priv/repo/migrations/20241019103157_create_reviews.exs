defmodule Zomato.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews) do
      add :rate, :integer
      add :description, :text
      add :likes, :integer, default: 0
      add :user_id, references(:users, on_delete: :delete_all)
      add :restaurant_id, references(:restraurents, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:reviews, [:user_id])
    create index(:reviews, [:restaurant_id])
  end
end
