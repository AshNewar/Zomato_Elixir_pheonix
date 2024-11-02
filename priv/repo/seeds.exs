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
        email: "zomato@gmail.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Angel",
        phone: "123-456-7890",
        address: "123 Elm St",
        profile_pic: "https://t.ly/AySsV"
      },
      %{
        email: "user2320@example.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Ramcharan",
        phone: "234-567-8901",
        address: "456 Oak St",
        profile_pic: "https://t.ly/AySsV"
      },
      %{
        email: "user3320@example.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Allen",
        phone: "345-678-9012",
        address: "789 Pine St",
        profile_pic: "https://t.ly/AySsV"
      },
      %{
        email: "user14320@example.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Joe Angel",
        phone: "123-456-7890",
        address: "123 Elm St",
        profile_pic: "https://t.ly/v1baJ"
      },
      %{
        email: "user23420@example.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Doe",
        phone: "234-567-8901",
        address: "456 Oak St",
        profile_pic: "https://t.ly/AySsV"
      },
      %{
        email: "user33420@example.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Kota",
        phone: "345-678-9012",
        address: "789 Pine St",
        profile_pic: "https://t.ly/v1baJ"
      },
      %{
        email: "user13240@example.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Ellie",
        phone: "123-456-7890",
        address: "123 Elm St",
        profile_pic: "https://t.ly/AySsV"
      },
      %{
        email: "user23204@example.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Newar",
        phone: "234-567-8901",
        address: "456 Oak St",
        profile_pic: "https://t.ly/AySsV"
      },
      %{
        email: "usss@example.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Ashish",
        phone: "345-678-9012",
        address: "789 Pine St",
        profile_pic: "https://t.ly/v1baJ"
      },
      %{
        email: "user3320224@example.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Edge",
        phone: "345-678-9012",
        address: "789 Pine St",
        profile_pic: "https://t.ly/v1baJ"
      },
      %{
        email: "us33204@example.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Karthik",
        phone: "345-678-9012",
        address: "789 Pine St",
        profile_pic: "https://t.ly/v1baJ"
      },%{
        email: "hello@example.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Hello",
        phone: "345-678-9012",
        address: "789 Pine St",
        profile_pic: "https://t.ly/AySsV"
      },%{
        email: "noice@example.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Nice",
        phone: "345-678-9012",
        address: "789 Pine St",
        profile_pic: "https://t.ly/v1baJ"
      },
      %{
        email: "hello11@example.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Hari",
        phone: "345-678-9012",
        address: "789 Pine St",
        profile_pic: "https://t.ly/AySsV"
      },%{
        email: "noice32@example.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Nanny",
        phone: "345-678-9012",
        address: "789 Pine St",
        profile_pic: "https://t.ly/AySsV"
      },
      %{
        email: "he11@example.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Harish",
        phone: "345-678-9012",
        address: "789 Pine St",
        profile_pic: "https://t.ly/AySsV"
      },%{
        email: "nooo32@example.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Naresh",
        phone: "345-678-9012",
        address: "789 Pine St",
        profile_pic: "https://t.ly/AySsV"
      }
    ]

    # Insert users into the database
    for user_attrs <- users do
      %User{}
      |> User.registration_changeset(user_attrs)
      |> Repo.insert!()
    end

    IO.puts("Seeded Users")

    restraurents = [
      %{
        email: "pasta_palace@gmail.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Pasta Palace",
        phone: "123-456-7891",
        address: "456 Maple Ave",
        profile_pic: "https://t.ly/wNlgn"
      },
      %{
        email: "sushi_central@gmail.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Sushi Central",
        phone: "987-654-3210",
        address: "789 Sushi St",
        profile_pic: "https://t.ly/wNlgn"
      },
      %{
        email: "burger_barn@gmail.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Burger Barn",
        phone: "456-789-0123",
        address: "123 Burger Ln",
        profile_pic: "https://t.ly/C_pRk"
      },
      %{
        email: "curry_house@gmail.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Curry House",
        phone: "321-654-9870",
        address: "101 Spice Blvd",
        profile_pic: "https://t.ly/wNlgn"
      },
      %{
        email: "taco_haven@gmail.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Taco Haven",
        phone: "654-321-0987",
        address: "202 Fiesta Rd",
        profile_pic: "https://t.ly/C_pRk"
      },
      %{
        email: "pancake_paradise@gmail.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Pancake Paradise",
        phone: "111-222-3333",
        address: "34 Breakfast Blvd",
        profile_pic: "https://t.ly/wNlgn"
      },
      %{
        email: "grill_master@gmail.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Grill Master",
        phone: "222-333-4444",
        address: "56 BBQ Rd",
        profile_pic: "https://t.ly/C_pRk"
      },
      %{
        email: "vegan_delights@gmail.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Vegan Delights",
        phone: "333-444-5555",
        address: "78 Plant Ln",
        profile_pic: "https://t.ly/wNlgn"
      },
      %{
        email: "noodle_house@gmail.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Noodle House",
        phone: "444-555-6666",
        address: "90 Noodle St",
        profile_pic: "https://t.ly/C_pRk"
      },
      %{
        email: "tandoori_express@gmail.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Tandoori Express",
        phone: "555-666-7777",
        address: "102 Spice Rd",
        profile_pic: "https://t.ly/wNlgn"
      },
      %{
        email: "pizza_palace@gmail.com",
        password: hash_password("12345678"),
        confirmed_at: DateTime.utc_now(),
        name: "Pizza Palace",
        phone: "666-777-8888",
        address: "123 Pizza Ln",
        profile_pic: "https://t.ly/wNlgn"
      }
    ]

    # Insert restraurent into the database
    for user_attrs <- restraurents do
      %Restraurent{}
      |> Restraurent.registration_changeset(user_attrs)
      |> Repo.insert!()
    end

    IO.puts("Seeded Restraurents")

    items = [
      %{
        restaurant_id: 1,
        price: 12,
        name: "Margherita Pizza",
        description: "Classic pizza with fresh basil.",
        photo_url: "https://t.ly/ZhtNp",
        no_of_orders: 50,
        category: "Pizza",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 1,
        price: 9,
        name: "Caesar Salad",
        description: "Crisp romaine with Caesar dressing.",
        photo_url: "https://t.ly/C_pRk",
        no_of_orders: 30,
        category: "Salad",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 2,
        price: 15,
        name: "Spaghetti Carbonara",
        description: "Pasta with creamy sauce and bacon.",
        photo_url: "https://t.ly/ZhtNp",
        no_of_orders: 40,
        category: "Pasta",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 2,
        price: 8,
        name: "Garlic Bread",
        description: "Toasted bread with garlic butter.",
        photo_url: "https://t.ly/C_pRk",
        no_of_orders: 20,
        category: "Appetizer",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 3,
        price: 10,
        name: "Beef Tacos",
        description: "Soft tacos with seasoned beef.",
        photo_url: "https://t.ly/ZhtNp",
        no_of_orders: 25,
        category: "Tacos",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 3,
        price: 5,
        name: "Chicken Wings",
        description: "Spicy wings served with ranch.",
        photo_url: "https://t.ly/ZhtNp",
        no_of_orders: 60,
        category: "Appetizer",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 4,
        price: 20,
        name: "Grilled Salmon",
        description: "Fresh salmon grilled to perfection.",
        photo_url: "https://t.ly/C_pRk",
        no_of_orders: 15,
        category: "Seafood",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 5,
        price: 6,
        name: "Chocolate Cake",
        description: "Decadent chocolate cake slice.",
        photo_url: "https://example.com/photos/chocolate_cake.jpg",
        no_of_orders: 35,
        category: "Dessert",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 5,
        price: 5,
        name: "Cheesecake",
        description: "Rich and creamy cheesecake with a graham cracker crust.",
        photo_url: "https://t.ly/ZhtNp",
        no_of_orders: 25,
        category: "Dessert",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 6,
        price: 10,
        name: "Margherita Pizza",
        description: "Classic pizza topped with tomatoes, fresh mozzarella, and basil.",
        photo_url: "https://example.com/photos/margherita_pizza.jpg",
        no_of_orders: 50,
        category: "Main Course",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 2,
        price: 12,
        name: "BBQ Chicken Pizza",
        description: "Pizza topped with BBQ chicken, onions, and mozzarella.",
        photo_url: "https://t.ly/C_pRk",
        no_of_orders: 40,
        category: "Main Course",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 3,
        price: 8,
        name: "Caesar Salad",
        description: "Classic Caesar salad with romaine, croutons, and parmesan.",
        photo_url: "https://t.ly/ZhtNp",
        no_of_orders: 15,
        category: "Appetizer",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 3,
        price: 7,
        name: "French Fries",
        description: "Golden crispy french fries, lightly salted.",
        photo_url: "https://example.com/photos/french_fries.jpg",
        no_of_orders: 60,
        category: "Side",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 4,
        price: 14,
        name: "Steak Sandwich",
        description: "Grilled steak with caramelized onions on a toasted bun.",
        photo_url: "https://t.ly/ZhtNp",
        no_of_orders: 30,
        category: "Main Course",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 4,
        price: 9,
        name: "Buffalo Wings",
        description: "Spicy buffalo wings with a side of ranch.",
        photo_url: "https://t.ly/ZhtNp",
        no_of_orders: 45,
        category: "Appetizer",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      },
      %{
        restaurant_id: 1,
        price: 6,
        name: "Chocolate Cake",
        description: "Decadent chocolate cake slice.",
        photo_url: "https://t.ly/C_pRk",
        no_of_orders: 35,
        category: "Dessert",
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      }
    ]


    for item_attrs <- items do
      %Item{}
      |> Item.changeset(item_attrs)
      |> Repo.insert!()
    end

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
        restaurant_id: 2,
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

    for review_attrs <- reviews do
      %Review{}
      |> Review.changeset(review_attrs)
      |> Repo.insert!()
    end

    IO.puts("Seeded Reviews")


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

    for follow <- follows_data do
      %Follower{follower_id: follow.follower_id, followed_id: follow.followed_id}
      |> Repo.insert!()
    end

    IO.puts("Inserted dummy follow data successfully!")


  end
end

# Run the seeder
Zomato.Seeds.run()
