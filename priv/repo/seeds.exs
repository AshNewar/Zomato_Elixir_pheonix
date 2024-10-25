# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Zomato.Repo.insert!(%Zomato.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.



alias Zomato.Repo
alias Zomato.Accounts.User

defmodule Zomato.Seeds do
  alias Zomato.Followers.Follower
  alias Zomato.Orders.Order
  alias Zomato.Reviews.Review
  alias Zomato.Item
  alias Zomato.Shops.Restraurent
  defp hash_password(password) do
    Bcrypt.hash_pwd_salt(password)
  end

  def run do
    users = [
      %{
        email: "user1320@example.com",
        password: hash_password("password1"),
        confirmed_at: DateTime.utc_now(),
        name: "Angel",
        phone: "123-456-7890",
        address: "123 Elm St",
        profile_pic: "https://example.com/profile1.jpg"
      },
      %{
        email: "user2320@example.com",
        password: hash_password("password2"),
        confirmed_at: DateTime.utc_now(),
        name: "Ramcharan",
        phone: "234-567-8901",
        address: "456 Oak St",
        profile_pic: "https://example.com/profile2.jpg"
      },
      %{
        email: "user3320@example.com",
        password: hash_password("password3"),
        confirmed_at: DateTime.utc_now(),
        name: "Allen",
        phone: "345-678-9012",
        address: "789 Pine St",
        profile_pic: "https://example.com/profile3.jpg"
      },
      %{
        email: "user14320@example.com",
        password: hash_password("password1"),
        confirmed_at: DateTime.utc_now(),
        name: "Angel",
        phone: "123-456-7890",
        address: "123 Elm St",
        profile_pic: "https://example.com/profile1.jpg"
      },
      %{
        email: "user23420@example.com",
        password: hash_password("password2"),
        confirmed_at: DateTime.utc_now(),
        name: "Ramcharan",
        phone: "234-567-8901",
        address: "456 Oak St",
        profile_pic: "https://example.com/profile2.jpg"
      },
      %{
        email: "user33420@example.com",
        password: hash_password("password3"),
        confirmed_at: DateTime.utc_now(),
        name: "Allen",
        phone: "345-678-9012",
        address: "789 Pine St",
        profile_pic: "https://example.com/profile3.jpg"
      },
      %{
        email: "user13240@example.com",
        password: hash_password("password1"),
        confirmed_at: DateTime.utc_now(),
        name: "Angel",
        phone: "123-456-7890",
        address: "123 Elm St",
        profile_pic: "https://example.com/profile1.jpg"
      },
      %{
        email: "user23204@example.com",
        password: hash_password("password2"),
        confirmed_at: DateTime.utc_now(),
        name: "Ramcharan",
        phone: "234-567-8901",
        address: "456 Oak St",
        profile_pic: "https://example.com/profile2.jpg"
      },
      %{
        email: "user33204@example.com",
        password: hash_password("password3"),
        confirmed_at: DateTime.utc_now(),
        name: "Allen",
        phone: "345-678-9012",
        address: "789 Pine St",
        profile_pic: "https://example.com/profile3.jpg"
      }
    ]

    # Insert users into the database
    # for user_attrs <- users do
    #   %User{}
    #   |> User.registration_changeset(user_attrs)
    #   |> Repo.insert!()
    # end

    IO.puts("Seeded Users")

    # Insert restraurent into the database
    # for user_attrs <- users do
    #   %Restraurent{}
    #   |> Restraurent.registration_changeset(user_attrs)
    #   |> Repo.insert!()
    # end

    IO.puts("Seeded Restraurents")

    items = [
      %{
        restaurant_id: 1,
        price: 12.99,
        name: "Margherita Pizza",
        description: "Classic pizza with fresh basil.",
        photo_url: "https://example.com/photos/margherita_pizza.jpg",
        no_of_orders: 50,
        category: "Pizza",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 1,
        price: 9.99,
        name: "Caesar Salad",
        description: "Crisp romaine with Caesar dressing.",
        photo_url: "https://example.com/photos/caesar_salad.jpg",
        no_of_orders: 30,
        category: "Salad",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 2,
        price: 15.49,
        name: "Spaghetti Carbonara",
        description: "Pasta with creamy sauce and bacon.",
        photo_url: "https://example.com/photos/spaghetti_carbonara.jpg",
        no_of_orders: 40,
        category: "Pasta",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 2,
        price: 8.50,
        name: "Garlic Bread",
        description: "Toasted bread with garlic butter.",
        photo_url: "https://example.com/photos/garlic_bread.jpg",
        no_of_orders: 20,
        category: "Appetizer",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 3,
        price: 10.99,
        name: "Beef Tacos",
        description: "Soft tacos with seasoned beef.",
        photo_url: "https://example.com/photos/beef_tacos.jpg",
        no_of_orders: 25,
        category: "Tacos",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 3,
        price: 5.99,
        name: "Chicken Wings",
        description: "Spicy wings served with ranch.",
        photo_url: "https://example.com/photos/chicken_wings.jpg",
        no_of_orders: 60,
        category: "Appetizer",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 4,
        price: 20.00,
        name: "Grilled Salmon",
        description: "Fresh salmon grilled to perfection.",
        photo_url: "https://example.com/photos/grilled_salmon.jpg",
        no_of_orders: 15,
        category: "Seafood",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 4,
        price: 6.99,
        name: "Chocolate Cake",
        description: "Decadent chocolate cake slice.",
        photo_url: "https://example.com/photos/chocolate_cake.jpg",
        no_of_orders: 35,
        category: "Dessert",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      }
    ]


    # for item_attrs <- items do
    #   %Item{}
    #   |> Item.changeset(item_attrs)
    #   |> Repo.insert!()
    # end

    IO.puts("Seeded Items")


    reviews = [
      %{
        rate: 5,
        description: "Amazing pizza! Fresh and delicious.",
        likes: 10,
        user_id: 1,
        restaurant_id: 1,
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        rate: 4,
        description: "Great atmosphere and friendly staff.",
        likes: 5,
        user_id: 2,
        restaurant_id: 1,
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        rate: 3,
        description: "Good pasta, but a bit overpriced.",
        likes: 2,
        user_id: 3,
        restaurant_id: 2,
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        rate: 4,
        description: "Tasty tacos! Will definitely come back.",
        likes: 8,
        user_id: 1,
        restaurant_id: 3,
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        rate: 2,
        description: "Wings were overcooked and too spicy.",
        likes: 1,
        user_id: 2,
        restaurant_id: 3,
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        rate: 5,
        description: "The grilled salmon was fantastic!",
        likes: 12,
        user_id: 3,
        restaurant_id: 4,
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        rate: 5,
        description: "Chocolate cake is a must-try!",
        likes: 15,
        user_id: 1,
        restaurant_id: 4,
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        rate: 4,
        description: "Nice place for family dinners.",
        likes: 7,
        user_id: 2,
        restaurant_id: 4,
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      }
    ]

    # for review_attrs <- reviews do
    #   %Review{}
    #   |> Review.changeset(review_attrs)
    #   |> Repo.insert!()
    # end

    # IO.puts("Seeded Reviews")


    # orders = [
    #   %{
    #     status: "completed",
    #     total_amount: 29,
    #     user_id: 1,
    #     cart_id: 1,
    #     restaurant_id: 1,
    #     inserted_at: DateTime.utc_now(),
    #     updated_at: DateTime.utc_now()
    #   },
    #   %{
    #     status: "pending",
    #     total_amount: 15,
    #     user_id: 2,
    #     cart_id: 2,
    #     restaurant_id: 2,
    #     inserted_at: DateTime.utc_now(),
    #     updated_at: DateTime.utc_now()
    #   },
    #   %{
    #     status: "completed",
    #     total_amount: 45,
    #     user_id: 3,
    #     cart_id: 3,
    #     restaurant_id: 3,
    #     inserted_at: DateTime.utc_now(),
    #     updated_at: DateTime.utc_now()
    #   },
    #   %{
    #     status: "completed",
    #     total_amount: 22,
    #     user_id: 1,
    #     cart_id: 4,
    #     restaurant_id: 4,
    #     inserted_at: DateTime.utc_now(),
    #     updated_at: DateTime.utc_now()
    #   },
    #   %{
    #     status: "pending",
    #     total_amount: 18,
    #     user_id: 2,
    #     cart_id: 5,
    #     restaurant_id: 1,
    #     inserted_at: DateTime.utc_now(),
    #     updated_at: DateTime.utc_now()
    #   },
    #   %{
    #     status: "completed",
    #     total_amount: 37,
    #     user_id: 3,
    #     cart_id: 6,
    #     restaurant_id: 2,
    #     inserted_at: DateTime.utc_now(),
    #     updated_at: DateTime.utc_now()
    #   },
    #   %{
    #     status: "completed",
    #     total_amount: 12,
    #     user_id: 1,
    #     cart_id: 7,
    #     restaurant_id: 3,
    #     inserted_at: DateTime.utc_now(),
    #     updated_at: DateTime.utc_now()
    #   },
    #   %{
    #     status: "pending",
    #     total_amount: 25,
    #     user_id: 2,
    #     cart_id: 8,
    #     restaurant_id: 4,
    #     inserted_at: DateTime.utc_now(),
    #     updated_at: DateTime.utc_now()
    #   }
    # ]

    # for order_attrs <- orders do
    #   %Order{}
    #   |> Order.changeset(order_attrs)
    #   |> Repo.insert!()
    # end\


    # IO.inspect("Seeded Orders")

    follows_data = [
      %{follower_id: 1, followed_id: 2},
      %{follower_id: 1, followed_id: 3},
      %{follower_id: 2, followed_id: 3},
      %{follower_id: 2, followed_id: 4},
      %{follower_id: 3, followed_id: 1},
      %{follower_id: 3, followed_id: 4},
      %{follower_id: 4, followed_id: 1},
      %{follower_id: 4, followed_id: 2},
      %{follower_id: 5, followed_id: 1},
      %{follower_id: 5, followed_id: 3}
    ]

    # for follow <- follows_data do
    #   %Follower{follower_id: follow.follower_id, followed_id: follow.followed_id}
    #   |> Repo.insert!()
    # end

    # IO.puts("Inserted dummy follow data successfully!")


  end
end

# Run the seeder
Zomato.Seeds.run()
