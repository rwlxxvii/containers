## atmos

Atmos is a workflow automation tool for DevOps that makes it more manageable to operate very large environments with DRY configuration.

demo:

https://www.youtube.com/watch?v=0dFEixCK0Wk&t=1415s

```sh
   │  
   │   # Centralized stacks configuration
   ├── stacks/
   │   │
   │   └── <stack_1>.yaml
   │   └── <stack_2>.yaml
   │   └── <stack_3>.yaml
   │  
   │   # Centralized components configuration. Components are broken down by tool
   ├── components/
   │   │
   │   ├── terraform/   # Terraform components (Terraform root modules)
   │   │   ├── infra/
   │   │   ├── mixins/
   │   │   ├── test/test-component/
   │   │   └── top-level-component1/
   │   │
   │   └── helmfile/  # Helmfile components are organized by Helm chart
   │       ├── echo-server/
   │       └── infra/infra-server
   │  
   │   # Root filesystem for the Docker image (see `Dockerfile`)
   ├── rootfs/
   │
   │   # Makefile for building the CLI
   ├── Makefile
   │   # Atmos CLI configuration
   ├── atmos.yaml
   │  
   │   # Docker image for shipping the CLI and all dependencies
   └── Dockerfile (optional)
```

## geodisec shell

Geodesic is the fastest way to get up and running with a rock solid, production grade cloud platform built entirely from Open Source technologies.

It’s a swiss army knife for creating and building consistent platforms to be shared across a team environment.

It easily versions staging environments in a repeatable manner that can be followed by any team member.

```sh

docker|podman run -it --rm --volume $HOME:/localhost docker.io/cloudposse/geodesic:latest-debian --login

# Geodesic version 2.8.0 based on Debian GNU/Linux 11 (bullseye) (11.8)

                                     dP                   oo
                                     88
    .d8888b. .d8888b. .d8888b. .d888b88 .d8888b. .d8888b. dP .d8888b.
    88'  `88 88ooood8 88'  `88 88'  `88 88ooood8 Y8ooooo. 88 88'  `""
    88.  .88 88.  ... 88.  .88 88.  .88 88.  ...       88 88 88.  ...
    `8888P88 `88888P' `88888P' `88888P8 `88888P' `88888P' dP `88888P'
         .88
     d8888P

IMPORTANT:
# Unless there were errors reported above,
#  * Your host $HOME directory should be available under `/localhost`
#  * Your host AWS configuration and credentials should be available
#  * Use Leapp on your host computer to manage your credentials
#  * Leapp is free, open source, and available from https://leapp.cloud
#  * Use AWS_PROFILE environment variable to manage your AWS IAM role
#  * You can interactively select AWS profiles via the `assume-role` command



| Documentation  | https://docs.cloudposse.com   | Check out documention              |
| Public Slack   | https://slack.cloudposse.com  | Active & friendly DevOps community |
| Paid Support   | hello@cloudposse.com          | Get help fast from the experts     |

help

```