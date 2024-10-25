defmodule Zomato.Repo.Migrations.CreateCartItems do
  use Ecto.Migration

  def change do
    create table(:cart_items) do
      add :quantity, :integer, default: 0
      add :user_id, references(:users, on_delete: :delete_all)
      add :item_id, references(:items, on_delete: :delete_all)
      add :cart_id, references(:carts, on_delete: :delete_all)
      add :restaurant_id, references(:restraurents, on_delete: :delete_all), null: false


      timestamps(type: :utc_datetime)
    end

    create index(:cart_items, [:user_id])
    create index(:cart_items, [:item_id])
    create index(:cart_items, [:cart_id])
    create index(:cart_items, [:restaurant_id])
  end
end
