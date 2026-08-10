import { getDrugFeedback } from '@/lib/actions/feedback'
import FeedbackAdminPage from '@/components/admin/FeedbackAdminPage'

export const dynamic = 'force-dynamic'

export default async function FeedbackAdminRoute({ params }) {
  const { lang } = await params
  const feedback = await getDrugFeedback()
  return <FeedbackAdminPage lang={lang} initialFeedback={feedback} />
}
