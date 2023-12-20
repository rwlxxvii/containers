#!/bin/bash

<<comment

kaniko: Build Container Images In Kubernetes.

comment

set -e

# no arguments passed
# or first arg is `-f` or `--some-option`
if [ "$#" -eq 0 -o "${1#-}" != "$1" ]; then
	# add our default arguments
	set -- dockerd \
		--host=unix:///var/run/docker.sock \
		--host=tcp://0.0.0.0:2375 \
		--storage-driver=vfs \
		"$@"
fi

if [ "$1" = 'dockerd' ]; then
	# if we're running Docker, let's pipe through dind
	# (and we'll run dind explicitly with "sh" since its shebang is /bin/bash)
	set -- sh "$(which dind)" "$@"
fi

# Create an ECS cluster:
aws ecs create-cluster --cluster-name kaniko-cluster

# Build and push the image to ECR:
docker build --tag ${KANIKO_BUILDER_REPO}:executor .

aws ecr get-login-password | docker login \
   --username AWS \
   --password-stdin \
   $KANIKO_BUILDER_REPO
   
docker push ${KANIKO_BUILDER_REPO}:executor

aws iam put-role-policy \
 --role-name kaniko_ecs_role \
 --policy-name kaniko_push_policy \
 --policy-document file://iam-role-policy.json

# Create an Amazon CloudWatch Log Group to Store Log Output
aws logs create-log-group \
  --log-group-name kaniko-builder

# Create an ECS task definition in which we define how the kaniko container will run, where the application source code repository is, and where to push the built container image:

# Register the ECS Task Definition.
aws ecs register-task-definition \
  --cli-input-json file://ecs-task-defintion.json

<< comment
Run kaniko as a single task using the ECS run-task API. 
This run-task API can be automated through a variety of CD and automation tools. 
If the subnet is a public subnet, the “assignPublicIp” field should be set to “ENABLED”.

Create a security group and create a kaniko task:

comment

# Run the ECS Task using the "Run Task" command:
aws ecs run-task \
    --task-definition kaniko:1 \
    --cli-input-json file://ecs-run-task.json
    
# Once the task starts you can view kaniko logs using CloudWatch:
aws logs get-log-events \
  --log-group-name kaniko-builder \
  --log-stream-name $(aws logs describe-log-streams \
     --log-group-name kaniko-builder \
     --query 'logStreams[0].logStreamName' --output text)

# List images in the kaniko repository:
aws ecr list-images --repository-name kaniko

exec "$@"
