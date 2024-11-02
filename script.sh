#!/bin/sh


echo "Creating the Database"

mix ecto.create
mix ecto.migrate

echo "Seeding the Database"

mix run priv/repo/seeds.exs

echo "Starting the Application"

mix phx.server

echo "Application Started at port 8000"
