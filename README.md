
# Zomato Food Delivery Website

App with funtionalities like Zomato with some addon 

## Features
- __Leader__ board to increase user enagment 
- __Chats Room__ using Pheonix Pub Sub
- Follow Friends and Friends Suggestions
- __Stripe Payment Gateway__ using Stripe webhooks
- __MailGun Mailing Service__
- Using __RabbitMQ__ to achieve asyncronous communication for sending emails
- __Nginx__ as Load Balancer



## Tech Stack

- __NGINX__
- __DOCKER__
- __RABBITMQ__
- __ELIXIR__
- __PHEONIX__
- __POSTGRES__

## Architecture

![image](https://github.com/user-attachments/assets/cad66172-9f32-4b90-92cb-6e1518bcba94)



## Installation

Clone my-project with git

```bash
  git clone <github_url> my_project
  cd my-project
```
__Note__ : 
- Docker daemon should be running on Your Machine
- Make Sure You are in the project folder

## Setup
Now Run the Docker commands
```bash
    docker compose up -d
```
__Running Ports__:
- Postgres - 5432 
- RabbitMQ - 5672 and 15672
- Nginx - 8000

Check the Server running in ``http://localhost:8000``


