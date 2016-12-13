# ecs-nginx-proxy
[![License](http://img.shields.io/badge/license-MIT-red.svg?style=flat)](./LICENSE)
[![Build Status](http://img.shields.io/travis/codesuki/ecs-nginx-proxy.svg?style=flat)](https://travis-ci.org/codesuki/ecs-nginx-proxy)
[![nginx latest](https://img.shields.io/badge/nginx-latest-brightgreen.svg?style=flat)](https://hub.docker.com/_/nginx/)
[![Docker Pulls](https://img.shields.io/docker/pulls/codesuki/ecs-nginx-proxy.svg)](https://hub.docker.com/r/codesuki/ecs-nginx-proxy/)

ecs-nginx-proxy lets you run a nginx reverse proxy in an AWS ECS cluster. <br/>
Uses [ecs-gen](https://github.com/codesuki/ecs-gen) to automatically make containers accessible by subdomain as they are started. <br/>
My use case is using a wildcard domain to make per branch test environments accessible by branch.domain.com. Heavily inspired by [nginx-proxy](https://github.com/jwilder/nginx-proxy).

## Security notice
Currently I am only using this for a development cluster in a private network. I advise against using this in a production environment. If you want to do this consider using [ecs-gen](https://github.com/codesuki/ecs-gen) to create your own nginx config + container setup which is as secure as you need it to be.

## Sample use case
You want to spin up development environments on AWS ECS for each pull request on your project.
How do you make this easy to use? Do you look up the instance IP and connect directly? <br/>
The easiest, at least for me, is to setup a wildcard DNS record and route to each deployed branch based on the subdomain, e.g. `*.domain.com`, `branch.domain.com`. <br/>
This projects enables you to do that.

## Usage
### Requirements
* Wildcard domain like `*.domain.com`
* ELB/ALB for this domain
* ECS Cluster
* EC2 instances in the cluster need a role including `ecs:Describe*` and `ecs:List*`
 * Easiest is to use `AmazonEC2ContainerServiceFullAccess` although that gives more permissions than needed

### Setup
* Create a new ECS task
 * Add a container using the `codesuki/ecs-nginx-proxy` docker image and make port 80 accessible
* Create a new service using the above task and a ELB
 * Connect to the ELB serving the wildcard domain

### Adding containers
Each container you want to make accessible needs to have its corresponding port mapped (can be random mapping) and the environment variable `VIRTUAL_HOST` set to the hostname it should respond to.

## Sample ECS task and service description
For reference JSON descriptions for the ecs-nginx-proxy [task](./examples/task.json), [service](./examples/service.json) and a [sample task](./examples/sample_task.json) can be found in the `examples/` folder.
Check out the commands below or just the sample descriptions if you already know how to work with AWS ECS.

To register the sample tasks and services with your AWS ECS cluster run the following commands.
### Register task
#### Requirements
* ECS Cluster
* Cluster EC2 instances need `ecs:Describe*` and `ecs:List*` permissions (see [Requirements](#usage) above)
```
aws ecs register-task-definition --cli-input-json file://./examples/task.json
```

### Register service
#### Requirements
* ELB or ALB + Target Group
* Service role for the ELB/ALB containing `AmazonEC2ContainerServiceRole`

#### If you use ELB
You need to supply the load balancer name.
```
aws ecs create-service --cluster <NAME> --role <NAME> --load-balancers loadBalancerName=<NAME>,containerName=ecs-nginx-proxy,containerPort=80 --cli-input-json file://./examples/service.json
```

#### If you use ALB
You need to supply the target group ARN.
```
aws ecs create-service --cluster <NAME> --role <NAME> --load-balancers targetGroupArn=<ARN>,containerName=ecs-nginx-proxy,containerPort=80 --cli-input-json file://./examples/service.json
```

### Register sample task
Before running the commands below change the `VIRTUAL_HOST` environment variable in [examples/samples_task.json](./examples/sample_task.json) to a domain corresponding to your load balancer setup.

```
aws ecs register-task-definition --cli-input-json file://./examples/sample_task.json
```

### Register sample service
```
aws ecs create-service --cluster <NAME> --service-name sample-service --task-definition sample-task --desired-count 1
```

## TODO
* Support SSL connections (for now you can do SSL termination at the ALB)
* Support path based routing (e.g. domain.com/service)
