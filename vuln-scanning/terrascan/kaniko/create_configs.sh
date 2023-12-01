#!/bin/bash

<<comment

Create supporting config's for kaniko to build image.
Increase fargate resources depending on your billing.

comment

# Create the Container Image Dockerfle
tee Dockerfile <<\EOF
FROM gcr.io/kaniko-project/executor:latest
COPY ./config.json /kaniko/.docker/config.json
EOF

# Create the Kaniko Config File for Registry Credentials
tee config.json <<\EOF
{ "credsStore": "ecr-login" }
EOF

# Create a trust policy
tee ecs-trust-policy.json <<\EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
EOF
 
# Create an IAM policy
tee iam-role-policy.json <<\EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:PutImage",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ],
            "Resource": "*"
        }
    ]
}
EOF

# Create the ECS Task Definition.
tee ecs-task-defintion.json <<\EOF
{
    "family": "kaniko",
    "taskRoleArn": "$ECS_TASK_ROLE",
    "executionRoleArn": "arn:aws:iam::${AWS_ACCOUNT_ID}:role/ecsTaskExecutionRole",
    "networkMode": "awsvpc",
    "containerDefinitions": [
        {
            "name": "kaniko",
            "image": "$KANIKO_BUILDER_IMAGE",
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "kaniko-builder",
                    "awslogs-region": "$(aws configure get region)",
                    "awslogs-stream-prefix": "kaniko"
                }
            },
            "command": [
                "--context", "git://github.com/rwlxxvii/apps.git",
                "--context-sub-path", "./terrascan",
                "--dockerfile", "Dockerfile",
                "--destination", "$KANIKO_IMAGE",
                "--force"
            ]
        }],
    "requiresCompatibilities": ["FARGATE"],
    "cpu": "512",
    "memory": "1024"
}
EOF

# Start the ECS Task
tee ecs-run-task.json <<\EOF
{
    "cluster": "kaniko-cluster",
    "count": 1,
    "launchType": "FARGATE",
    "networkConfiguration": {
        "awsvpcConfiguration": {
            "subnets": ["$KANIKO_SUBNET"],
            "securityGroups": ["$KANIKO_SECURITY_GROUP"],
            "assignPublicIp": "DISABLED"
        }
    },
    "platformVersion": "1.4.0"
}
EOF
