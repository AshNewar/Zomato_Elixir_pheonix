
# Zomato Food Delivery Website

App with funtionalities like Zomato 

## Features
- __Leader__ board to increase user enagment 
- __Chats Room__ using Pheonix Pub Sub
- Follow Friends and Friends Suggestions
- __Stripe Payment Gateway__ using Stripe webhooks
- __MailGun Mailing Service__
- Using __RabbitMQ__ to achieve asyncronous communication for sending emails
- __Nginx__ as Load Balancer
- Trending Restraurents and Foods




## Tech Stack

- __NGINX__
- __DOCKER__
- __RABBITMQ__
- __ELIXIR__
- __PHEONIX__
- __POSTGRES__

## Architecture

![image](https://github.com/user-attachments/assets/fbe9e58a-f367-4755-adae-b652a6607158)


## Steps
### Installation

Clone my-project with git

```bash
  git clone https://github.com/AshNewar/Zomato_Elixir_pheonix.git zomato
  cd zomato
```
__Note__ : 
- Docker daemon should be running on Your Machine
- Make Sure You are in the project folder

### Setup
Now Run the Docker commands
```bash
    docker compose up -d
```
__Note__:
- Postgres - 5432 
- RabbitMQ - 5672 and 15672
- Nginx - 8000

Check the Server running in ``http://localhost:8000``

__NOTE__ : It may take some time as NGINX is setting up the proxy

### Seeding Datas
```
docker exec -it zomato-web-1 bash
export DATABASE_URL="ecto://postgres:postgres@db/zomato"
export SECRET_KEY_BASE="FMsGFPifCUmZPT0R95ddfG1veLdmUG68+uTLZUqvrYDvyqJPMu0HhUCG9BZQ/0Ht"
MIX_ENV=prod  mix run priv/repo/seeds.exs
```



