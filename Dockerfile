FROM nginx:latest

# apply fix for very long server names
RUN sed -i 's/^http {/&\n    server_names_hash_bucket_size 128;/g' /etc/nginx/nginx.conf

WORKDIR /root/

RUN apt-get update && apt-get install -y -q --no-install-recommends curl unzip ca-certificates && apt-get clean

# download release of ecs-gen
ENV ECS_GEN_RELEASE 0.5.0
RUN curl -OL https://github.com/codesuki/ecs-gen/releases/download/$ECS_GEN_RELEASE/ecs-gen-linux-amd64.zip && unzip ecs-gen-linux-amd64.zip && cp ecs-gen-linux-amd64 /usr/local/bin/ecs-gen

COPY nginx.tmpl nginx.tmpl

CMD nginx && ecs-gen --signal="nginx -s reload" --template=nginx.tmpl --output=/etc/nginx/conf.d/default.conf
