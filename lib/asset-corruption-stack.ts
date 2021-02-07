import * as cdk from '@aws-cdk/core';
import * as s3 from '@aws-cdk/aws-s3';
import * as s3Deployment from '@aws-cdk/aws-s3-deployment';

export class Issue12536AssetCorruptionStack extends cdk.Stack {
  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const destination = new s3.Bucket(this, 'Destination', {
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      autoDeleteObjects: true,
    });

    new s3Deployment.BucketDeployment(this, 'Deployment', {
      sources: [s3Deployment.Source.asset(`${__dirname}/asset`)],
      destinationBucket: destination,
    });

  }
}
