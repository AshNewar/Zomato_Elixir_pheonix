defmodule Zomato.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :restaurant_id, references(:restraurents, on_delete: :delete_all), null: false
      add :price, :integer, null: false
      add :name, :string, null: false
      add :description, :text
      add :photo_url, :string
      add :no_of_orders, :integer, default: 0
      add :category, :string

      timestamps()
    end

    # Creating an index on restaurant_id for faster lookups
    create index(:items, [:restaurant_id])
  end
end
