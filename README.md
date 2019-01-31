# docker-ttrss
Tiny Tiny RSS in Docker with LDAP and International Support.

This container runs off the official PHP container with apache. It adds supervisord to handle running apache and feed updates in the same container.

## Usage
The below will set up the containers required for tt-rss. You should seperatly set up an nginx instance proxying to `ttrss:80`, or you could open ports to the host.

In your `docker-compose.yml`:
```
version: '2.1'

services:

  ttrss-mariadb:
    image: mariadb
    container_name: ttrss-mariadb
    environment:
      - MYSQL_ROOT_PASSWORD=ttrss
      - MYSQL_PASSWORD=ttrss
      - MYSQL_DATABASE=ttrss
      - MYSQL_USER=ttrss
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./ttrss/mariadb/data/:/var/lib/mysql
    restart: always

  ttrss:
    image: nowsci/docker-ttrss
    container_name: ttrss
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./ttrss/apache/data:/data
    depends_on:
      - ttrss-mariadb
    restart: always
```
