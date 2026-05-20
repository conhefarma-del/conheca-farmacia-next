// Teste para a função getAdminUsersCount
const { getAdminUsersCount } = require('../../lib/api.js');
const { supabaseClient } = require('../../config.js');

jest.mock('../../config.js');

describe('getAdminUsersCount', () => {
  test('should return count of admin users', async () => {
    supabaseClient.from.mockReturnValue({
      select: () => ({
        eq: () => ({
          count: 5,
          error: null
        })
      })
    });

    const count = await getAdminUsersCount();
    expect(count).toBe(5);
  });

  test('should return 0 when there is an error', async () => {
    supabaseClient.from.mockReturnValue({
      select: () => ({
        eq: () => ({
          count: null,
          error: new Error('Database error')
        })
      })
    });

    const count = await getAdminUsersCount();
    expect(count).toBe(0);
  });
});