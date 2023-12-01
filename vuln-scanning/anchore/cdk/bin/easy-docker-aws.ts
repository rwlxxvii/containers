#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { EasyDockerAwsStack } from "../lib/easy-docker-aws-stack";

const app = new cdk.App();
const stackProps = {
  env: {
    region: process.env.REGION,
    account: process.env.ACCOUNT_ID,
    privileged: true,
  },
};

new EasyDockerAwsStack(app, "EasyDockerAwsStack", stackProps);
