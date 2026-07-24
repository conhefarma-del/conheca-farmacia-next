import { isValidHexColor, validateUrl } from './security'

describe('isValidHexColor', () => {
  it('aceita #00493A e #2E8B6F', () => {
    expect(isValidHexColor('#00493A')).toBe(true)
    expect(isValidHexColor('#2E8B6F')).toBe(true)
  })

  it('aceita RGB abreviado (#RGB)', () => {
    expect(isValidHexColor('#FFF')).toBe(true)
    expect(isValidHexColor('#000')).toBe(true)
  })

  it('rejeita cor sem #', () => {
    expect(isValidHexColor('00493A')).toBe(false)
  })

  it('rejeita string vazia', () => {
    expect(isValidHexColor('')).toBe(false)
  })

  it('rejeita cor com caracteres inválidos', () => {
    expect(isValidHexColor('#ZZZ')).toBe(false)
  })

  it('rejeita nomes de cor CSS', () => {
    expect(isValidHexColor('red')).toBe(false)
    expect(isValidHexColor('green')).toBe(false)
  })

  it('rejeita valores não-string', () => {
    expect(isValidHexColor(null)).toBe(false)
    expect(isValidHexColor(undefined)).toBe(false)
    expect(isValidHexColor(123)).toBe(false)
    expect(isValidHexColor({})).toBe(false)
  })

  it('aceita cor com trim', () => {
    expect(isValidHexColor('  #00493A  ')).toBe(true)
  })
})

describe('validateUrl', () => {
  it('aceita http URLs', () => {
    expect(validateUrl('http://example.com')).toBe('http://example.com')
  })

  it('aceita https URLs', () => {
    expect(validateUrl('https://conhecafarmacia.com')).toBe('https://conhecafarmacia.com')
  })

  it('rejeita javascript: URLs', () => {
    expect(validateUrl('javascript:alert(1)')).toBe('#')
  })

  it('rejeita data: URLs', () => {
    expect(validateUrl('data:text/html,<script>alert(1)</script>')).toBe('#')
  })

  it('rejeita string vazia', () => {
    expect(validateUrl('')).toBe('#')
  })

  it('rejeita null/undefined', () => {
    expect(validateUrl(null)).toBe('#')
    expect(validateUrl(undefined)).toBe('#')
  })

  it('rejeita URLs sem ://', () => {
    expect(validateUrl('httpfoo://evil')).toBe('#')
    expect(validateUrl('http')).toBe('#')
    expect(validateUrl('https')).toBe('#')
  })

  it('rejeita números', () => {
    expect(validateUrl(123)).toBe('#')
  })
})
