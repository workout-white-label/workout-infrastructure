import assert from 'node:assert/strict';
import test from 'node:test';
import { claimsToAddOrOverride, toAccessTokenClaims } from './claims-mapper.ts';
import { createHandler } from './handler.ts';
import type { UserApiResponse } from './claims.ts';
import type { PreTokenGenerationV2TriggerEvent } from 'aws-lambda';
import { UserManagerClient } from './user-manager-client.ts';

const sampleUser: UserApiResponse = {
  id: '11111111-1111-1111-1111-111111111111',
  cognitoUserId: 'cognito-trainer',
  tenantId: '00000000-0000-0000-0000-000000000001',
  email: 'trainer@workout.local',
  firstName: 'Test',
  lastName: 'Trainer',
  role: 'TRAINER',
  status: 'ACTIVE',
  permissions: ['user:read', 'workout:create'],
  createdAt: '2026-01-01T00:00:00Z',
  updatedAt: '2026-01-01T00:00:00Z',
};

test('toAccessTokenClaims maps user-manager response to jwt claims', () => {
  const claims = toAccessTokenClaims(sampleUser);

  assert.equal(claims.userId, sampleUser.id);
  assert.equal(claims.role, 'TRAINER');
  assert.deepEqual(claims.permissions, ['user:read', 'workout:create']);
  assert.equal(claims.tenantId, sampleUser.tenantId);
});

test('claimsToAddOrOverride uses camelCase claim names', () => {
  const claims = claimsToAddOrOverride(toAccessTokenClaims(sampleUser));

  assert.equal(claims.userId, sampleUser.id);
  assert.equal(claims.role, 'TRAINER');
  assert.deepEqual(claims.permissions, ['user:read', 'workout:create']);
});

test('handler enriches access and id tokens with user-manager claims', async () => {
  const client = new UserManagerClient('http://user-manager.test', 'secret', async () =>
    new Response(JSON.stringify([sampleUser]), { status: 200 }),
  );

  const handler = createHandler(client);
  const event = {
    request: {
      userAttributes: {
        sub: 'cognito-trainer',
      },
    },
    response: {},
  } as PreTokenGenerationV2TriggerEvent;

  const result = await handler(event, {} as never, () => undefined);

  assert.equal(
    result.response.claimsAndScopeOverride?.accessTokenGeneration?.claimsToAddOrOverride?.role,
    'TRAINER',
  );
  assert.deepEqual(
    result.response.claimsAndScopeOverride?.accessTokenGeneration?.claimsToAddOrOverride?.permissions,
    ['user:read', 'workout:create'],
  );
});
