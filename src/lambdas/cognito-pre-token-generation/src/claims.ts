export const JWT_CLAIMS = {
  USER_ID: 'userId',
  TENANT_ID: 'tenantId',
  EMAIL: 'email',
  FIRST_NAME: 'firstName',
  LAST_NAME: 'lastName',
  ROLE: 'role',
  STATUS: 'status',
  PERMISSIONS: 'permissions',
  CREATED_AT: 'createdAt',
  UPDATED_AT: 'updatedAt',
} as const;

export type UserApiResponse = {
  id: string;
  cognitoUserId: string;
  tenantId: string | null;
  email: string;
  firstName: string;
  lastName: string;
  role: string;
  status: string;
  permissions: string[];
  createdAt: string;
  updatedAt: string;
};

export type UserManagerClaims = {
  userId: string;
  tenantId?: string;
  email: string;
  firstName: string;
  lastName: string;
  role: string;
  status: string;
  permissions: string[];
  createdAt: string;
  updatedAt: string;
};
