import * as cdk from 'aws-cdk-lib';
import ec2 from 'aws-cdk-lib/aws-ec2';
import ecs from 'aws-cdk-lib/aws-ecs';
import ecs_patterns from 'aws-cdk-lib/aws-ecs-patterns';
import { DockerImageAsset } from 'aws-cdk-lib/aws-ecr-assets';
import { join } from 'path';

export class EasyDockerAwsStack extends cdk.Stack {
  constructor(scope: cdk.App, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const image = new DockerImageAsset(this, "BackendImage", {
      directory: join(__dirname, "..", "service"),
    });

    // At least 2 AZ required
    const vpc = new ec2.Vpc(this, "ApplicationVpc", { maxAzs: 2 });

    const cluster = new ecs.Cluster(this, "Cluster", {
      vpc,
    });

    // Create a load-balanced Fargate service and make it public
    new ecs_patterns.ApplicationLoadBalancedFargateService(
      this,
      "ApplicationFargateService",
      {
        cluster: cluster,
        cpu: 256,
        desiredCount: 1,
        taskImageOptions: {
          image: ecs.ContainerImage.fromDockerImageAsset(image),
        },
        memoryLimitMiB: 512,
        publicLoadBalancer: true,
      }
    );
  }
}
