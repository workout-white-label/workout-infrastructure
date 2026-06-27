import type { UserApiResponse, UserManagerClaims } from './claims.ts';
import { JWT_CLAIMS } from './claims.ts';

export function toAccessTokenClaims(user: UserApiResponse): UserManagerClaims {
  const claims: UserManagerClaims = {
    userId: user.id,
    email: user.email,
    firstName: user.firstName,
    lastName: user.lastName,
    role: user.role,
    status: user.status,
    permissions: [...user.permissions].sort(),
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
  };

  if (user.tenantId) {
    claims.tenantId = user.tenantId;
  }

  return claims;
}

export function claimsToAddOrOverride(claims: UserManagerClaims): Record<string, string | string[]> {
  const result: Record<string, string | string[]> = {
    [JWT_CLAIMS.USER_ID]: claims.userId,
    [JWT_CLAIMS.EMAIL]: claims.email,
    [JWT_CLAIMS.FIRST_NAME]: claims.firstName,
    [JWT_CLAIMS.LAST_NAME]: claims.lastName,
    [JWT_CLAIMS.ROLE]: claims.role,
    [JWT_CLAIMS.STATUS]: claims.status,
    [JWT_CLAIMS.PERMISSIONS]: claims.permissions,
    [JWT_CLAIMS.CREATED_AT]: claims.createdAt,
    [JWT_CLAIMS.UPDATED_AT]: claims.updatedAt,
  };

  if (claims.tenantId) {
    result[JWT_CLAIMS.TENANT_ID] = claims.tenantId;
  }

  return result;
}
