import { defineStorage } from '@aws-amplify/backend';

export const storage = defineStorage({
  name: 'clientFiles',
  access: (allow) => ({
    '/*': [
      allow.guest.to(['read', 'write', 'delete']),
      allow.authenticated.to(['read', 'write', 'delete'])
    ]
  })
});
