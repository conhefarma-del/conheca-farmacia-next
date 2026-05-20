// Teste para a função getUniqueCategoriesCount
const { getUniqueCategoriesCount } = require('../../lib/api.js');
const { supabaseClient } = require('../../config.js');

jest.mock('../../config.js');

describe('getUniqueCategoriesCount', () => {
  test('should return count of unique categories', async () => {
    // Mock responses for each table
    supabaseClient.from.mockImplementation((table) => {
      const selectMock = jest.fn().mockReturnValue({
        eq: jest.fn().mockReturnValue({
          not: jest.fn().mockReturnValue({
            // Return different categories for each table
            articles: () => ({
              data: [{ category: 'saude' }, { category: 'bemestar' }, { category: 'saude' }], // duplicate saude
              error: null
            }),
            events: () => ({
              data: [{ category: 'bemestar' }, { category: 'curso' }], // bemestar duplicate, curso new
              error: null
            }),
            lives: () => ({
              data: [{ category: 'saude' }, { category: 'entretenimento' }], // saude duplicate, entretenimento new
              error: null
            })
          }[table])
        })
      });
      return { select: selectMock };
    });

    const count = await getUniqueCategoriesCount();
    // Expected unique categories: saude, bemestar, curso, entretenimento = 4
    expect(count).toBe(4);
  });

  test('should return 0 when there is an error', async () => {
    supabaseClient.from.mockImplementation(() => ({
      select: () => ({
        eq: () => ({
          not: () => ({
            // Simulate error for any table
            articles: () => ({
              data: null,
              error: new Error('Database error')
            })
          })
        })
      })
    }));

    const count = await getUniqueCategoriesCount();
    expect(count).toBe(0);
  });
});