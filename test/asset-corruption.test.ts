import { expect as expectCDK, matchTemplate, MatchStyle } from '@aws-cdk/assert';
import * as cdk from '@aws-cdk/core';
import * as AssetCorruption from '../lib/asset-corruption-stack';

test('Empty Stack', () => {
    const app = new cdk.App();
    // WHEN
    const stack = new AssetCorruption.Issue12536AssetCorruptionStack(app, 'MyTestStack');
    // THEN
    expectCDK(stack).to(matchTemplate({
      "Resources": {}
    }, MatchStyle.EXACT))
});
