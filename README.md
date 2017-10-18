
# Docker Image for Seafile Pro Edition using mysql && sqlite3

## docker-compose.yml

Edit this `docker-compose.yml`
```
mysqlseafile:      #sqlite not need this
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
        - mysqlseafile:db #sqlite not need this
    volumes:
        - /mnt/cloud/seafile:/opt/seafile
    environment:
        - RESET=1   #reset sh file
        - PUID=<uid>
        - PGID=<gid>
    ports:
        - "9000:8000"
        - "8082:8082"
```


## Setup  

docker-compose run --rm seafile setup           #use mysql  
docker-compose run --rm seafile setup_sqlite    #use sqlite3  

## Run

docker-compose up -d  

## shell

docker-compose run --rm seafile bash  

## search update

docker-compose exec seafile /init search_update  

