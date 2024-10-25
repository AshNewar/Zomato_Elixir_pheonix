#!/bin/sh

echo "Starting the application"

mix ecto.create 
mix ecto.migrate 
mix phx.server

echo "Application started"
