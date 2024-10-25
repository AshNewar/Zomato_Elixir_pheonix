defmodule Zomato.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :status, :string
      add :total_amount, :integer
      add :user_id, references(:users, on_delete: :nothing)
      add :cart_id, references(:carts, on_delete: :nothing)
      add :restaurant_id, references(:restraurents, on_delete: :nothing)


      timestamps(type: :utc_datetime)
    end

    create index(:orders, [:user_id])
    create index(:orders, [:cart_id])
  end
end
