import type { UserApiResponse } from './claims.ts';

const INTERNAL_API_KEY_HEADER = 'X-Internal-Api-Key';
const ACTIVE_STATUS = 'ACTIVE';

export class UserManagerClient {
  private readonly baseUrl: string;
  private readonly internalApiKey: string;
  private readonly fetchImpl: typeof fetch;

  constructor(baseUrl: string, internalApiKey: string, fetchImpl: typeof fetch = fetch) {
    this.baseUrl = baseUrl;
    this.internalApiKey = internalApiKey;
    this.fetchImpl = fetchImpl;
  }

  async getUserByCognitoId(cognitoUserId: string): Promise<UserApiResponse> {
    const url = new URL('/users', this.baseUrl);
    url.searchParams.set('cognitoId', cognitoUserId);

    const response = await this.fetchImpl(url, {
      method: 'GET',
      headers: {
        [INTERNAL_API_KEY_HEADER]: this.internalApiKey,
        Accept: 'application/json',
      },
    });

    if (!response.ok) {
      const body = await response.text();
      throw new Error(
        `user-manager lookup failed with status ${response.status}: ${body}`,
      );
    }

    const users = (await response.json()) as UserApiResponse[];

    if (users.length === 0) {
      throw new UserNotRegisteredError(cognitoUserId);
    }

    const user = users[0];
    if (user.status !== ACTIVE_STATUS) {
      throw new UserNotActiveError(cognitoUserId);
    }

    return user;
  }
}

export class UserNotRegisteredError extends Error {
  constructor(cognitoUserId: string) {
    super(`No active user found for cognito id ${cognitoUserId}`);
    this.name = 'UserNotRegisteredError';
  }
}

export class UserNotActiveError extends Error {
  constructor(cognitoUserId: string) {
    super(`User is not active for cognito id ${cognitoUserId}`);
    this.name = 'UserNotActiveError';
  }
}

export function createUserManagerClientFromEnv(
  env: NodeJS.ProcessEnv = process.env,
  fetchImpl: typeof fetch = fetch,
): UserManagerClient {
  const baseUrl = env.USER_MANAGER_BASE_URL;
  const internalApiKey = env.INTERNAL_API_KEY;

  if (!baseUrl) {
    throw new Error('USER_MANAGER_BASE_URL is required');
  }

  if (!internalApiKey) {
    throw new Error('INTERNAL_API_KEY is required');
  }

  return new UserManagerClient(baseUrl, internalApiKey, fetchImpl);
}
