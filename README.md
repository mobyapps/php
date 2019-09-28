# Dockerfile for php

Usage
-------------
docker-compose.yml

```
version: "3"

services:
  php:
    image: charescape/php:7.3.10.0
    volumes:
      - vhosts:/usr/local/nginx/vhosts
    ports:
      - "9000:9000"
    networks:
      - php
    logging:
      driver: "json-file"
      options:
        max-size: "500k"
        max-file: "20"

networks:
  php:
    driver: bridge

volumes:
  vhosts:
    driver: local
```

Note
-------------
| Option | Default | Current
| --- | --- | ---
| session.cookie_secure | off | on
| session.name | PHPSESSID | SERVSESSID
| session.cookie_httponly | - | 1
| session.cookie_samesite | - | Lax

