// Teste para a função getArticlesLast30DaysCount
const { getArticlesLast30DaysCount } = require('../../lib/api.js');
const { supabaseClient } = require('../../config.js');

jest.mock('../../config.js');

describe('getArticlesLast30DaysCount', () => {
  test('should return count of articles published in last 30 days', async () => {
    supabaseClient.from.mockReturnValue({
      select: () => ({
        eq: () => ({
          gte: () => ({
            count: 8,
            error: null
          })
        })
      })
    });

    const count = await getArticlesLast30DaysCount();
    expect(count).toBe(8);
  });

  test('should return 0 when there is an error', async () => {
    supabaseClient.from.mockReturnValue({
      select: () => ({
        eq: () => ({
          gte: () => ({
            count: null,
            error: new Error('Database error')
          })
        })
      })
    });

    const count = await getArticlesLast30DaysCount();
    expect(count).toBe(0);
  });
});