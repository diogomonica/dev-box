# dev-box

- Setup new box
- SSH to new box with vscode-server port-forward: ssh -L 0.0.0.0:8080:localhost:8080 dev
- git clone this repo
- cd dev-box; bash dev-box.sh

## Build the container

> docker build -t code-server .

## Run the container

> docker run -it --rm --name code-server --security-opt=seccomp:unconfined -p 127.0.0.1:8080:8080 -v $(pwd)/project:/home/diogo/project code-server

## Tunnel to access port

> ssh -L 0.0.0.0:8080:localhost:8080 dev
