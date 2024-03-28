# 4640 "app" components

## Included material

- backend:
  - backend binary, hello-server
  - service file for backend, hello-server.service
    - service file includes info about where the binary should be on your server
  - caddy file(this just exposes the backend on port 80), Caddyfile
- frontend:
  - frontend, index.html
  - nginx configuration file, hello.conf
    - The nginx configuration file needs to be edited

## about the backend

'hello-server' exposes localhost:8080/echo

This just echos back a post request message. An example curl command has been included for testing the backend. If everything is setup you will see your message echoed back to you.

## Where should these files go

- backend(hello-server) and frontend(index.html): 
  - the files above provide the file paths (see service and nginx config)
- Caddyfile `/etc/caddy`
- hello-server.service `/etc/systemd/system`

## Example curl commands for testing your server

Replace the IP address in the examples with the IP address of your servers

Run these commands from your host machine, not your server.

### Testing your frontend

```bash
curl http://146.190.12.184
```

### Testing your backend

```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"message": "Hello from your server"}' \
  http://146.190.12.184/echo
```
