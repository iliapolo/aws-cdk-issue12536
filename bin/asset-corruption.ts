#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from '@aws-cdk/core';
import { AssetCorruptionStack } from '../lib/asset-corruption-stack';

const app = new cdk.App();
new AssetCorruptionStack(app, 'AssetCorruptionStack');
