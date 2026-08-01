import { BookOpen, HeartHandshake, Microscope, Pill, Stethoscope } from 'lucide-react'

// Ícones Lucide por nome (guardado na coluna icon_emoji — nome do ícone, sem emojis).
// Fallback: BookOpen para cursos sem ícone definido.
const ICONS = {
  Pill,
  Stethoscope,
  HeartHandshake,
  Microscope,
  BookOpen,
}

export default function GuideCourseIcon({ name, size = 32, className }) {
  const Icon = ICONS[name] || BookOpen
  return <Icon size={size} className={className} aria-hidden="true" />
}
