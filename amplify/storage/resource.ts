import { defineStorage } from '@aws-amplify/backend';

export const storage = defineStorage({
  name: 'clientFiles',
  access: (allow) => ({
    'public/*': [
      allow.authenticated.to(['read', 'write', 'delete'])
    ],
    'documents/*': [
      allow.authenticated.to(['read', 'write', 'delete'])
    ]
  })
});
