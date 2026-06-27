import type { PreTokenGenerationV2TriggerEvent, PreTokenGenerationV2TriggerHandler } from 'aws-lambda';
import { claimsToAddOrOverride, toAccessTokenClaims } from './claims-mapper.ts';
import { createUserManagerClientFromEnv } from './user-manager-client.ts';

function resolveCognitoUserId(event: PreTokenGenerationV2TriggerEvent): string {
  const sub = event.request.userAttributes.sub;
  if (!sub) {
    throw new Error('Cognito event is missing request.userAttributes.sub');
  }
  return sub;
}

export const createHandler = (
  userManagerClient = createUserManagerClientFromEnv(),
): PreTokenGenerationV2TriggerHandler => {
  return async (event) => {
    const cognitoUserId = resolveCognitoUserId(event);
    const user = await userManagerClient.getUserByCognitoId(cognitoUserId);
    const claims = toAccessTokenClaims(user);

    event.response.claimsAndScopeOverride = {
      accessTokenGeneration: {
        claimsToAddOrOverride: claimsToAddOrOverride(claims),
      },
      idTokenGeneration: {
        claimsToAddOrOverride: claimsToAddOrOverride(claims),
      },
    };

    return event;
  };
};

let cachedHandler: PreTokenGenerationV2TriggerHandler | undefined;

export const handler: PreTokenGenerationV2TriggerHandler = async (event, context, callback) => {
  cachedHandler ??= createHandler();
  return cachedHandler(event, context, callback);
};
