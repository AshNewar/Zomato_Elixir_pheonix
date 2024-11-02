FROM elixir:1.14-alpine

RUN apk add --no-cache build-base git nodejs npm bash

ENV MIX_ENV=prod

RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /app
COPY . .

RUN MIX_ENV=prod mix do deps.get, deps.compile

RUN npm install --prefix ./assets
RUN npm run --prefix ./assets build

RUN mix phx.digest

RUN mix compile

EXPOSE 4000

CMD ["sh", "-c", "mix ecto.create && mix ecto.migrate && mix run priv/repo/seeds.exs && mix phx.server"]
