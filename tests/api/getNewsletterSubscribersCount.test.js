// Teste para a função getNewsletterSubscribersCount
const { getNewsletterSubscribersCount } = require('../../lib/api.js');
const { supabaseClient } = require('../../config.js');

jest.mock('../../config.js');

describe('getNewsletterSubscribersCount', () => {
  test('should return count of active newsletter subscribers', async () => {
    supabaseClient.from.mockReturnValue({
      select: () => ({
        eq: () => ({
          count: 1250,
          error: null
        })
      })
    });

    const count = await getNewsletterSubscribersCount();
    expect(count).toBe(1250);
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

    const count = await getNewsletterSubscribersCount();
    expect(count).toBe(0);
  });
});