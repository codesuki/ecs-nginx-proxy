FROM nginx:latest

WORKDIR /root/

RUN apt-get update && apt-get install -y -q --no-install-recommends curl unzip && apt-get clean

# download release of ecs-gen
RUN curl -O $(curl -s https://api.github.com/repos/codesuki/ecs-gen/releases/latest | grep '"tag_name":' | sed -E 's|"tag_name": "([a-zA-Z0-9.]*)",|https://github.com/codesuki/ecs-gen/releases/download/\1/ecs-gen-linux-amd64.zip|') && unzip ecs-gen-linux-amd64.zip && cp ecs-gen-linux-amd64 /usr/local/bin/ecs-gen

COPY nginx.tmpl nginx.tmpl

CMD nginx && ecs-gen --signal="nginx -s reload" --template=nginx.tmpl --output=/etc/nginx/conf.d/default.conf
