#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from '@aws-cdk/core';
import { Issue12536AssetCorruptionStack } from '../lib/asset-corruption-stack';

const app = new cdk.App();
new Issue12536AssetCorruptionStack(app, 'Issue12536AssetCorruptionStack');
