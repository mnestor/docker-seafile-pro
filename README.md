
# Docker Image for Seafile Pro Edition using MySql

## docker-compose.yml

Edit this `docker-compose.yml`
```
mysqlseafile:
    image: mysql:5.7
    volumes:
        - /mnt/cloud/mysqlseafile:/var/lib/mysql 
    environment:
        - MYSQL_ROOT_PASSWORD=******
        - MYSQL_USER=seafile
        - MYSQL_PASSWORD=******
seafile:
   image: fcying/seafile-pro-mysql:latest
   links:
      - mysqlseafile:db
   volumes:
      - /mnt/cloud/seafile:/opt/seafile
   ports:
      - "9000:8000"
      - "8082:8082"
```

## Setup

docker-compose run --rm seafile setup

## Run

docker-compose up -d

## shell

docker-compose run --rm seafile bash

