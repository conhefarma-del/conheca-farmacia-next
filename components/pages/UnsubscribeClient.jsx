'use client'

import { useState, useEffect, useContext } from 'react'
import { useSearchParams } from 'next/navigation'
import Link from 'next/link'
import { LangContext } from '@/lib/contexts'
import { createClient } from '../../lib/supabase/client'

export default function UnsubscribeClient({ lang }) {
  const { t } = useContext(LangContext)
  const searchParams = useSearchParams()
  const token = searchParams.get('token')

  const [state, setState] = useState('loading') // loading | success | error
  const [errorMsg, setErrorMsg] = useState('')

  useEffect(() => {
    if (!token) {
      setErrorMsg(t('unsubscribe.error_message'))
      setState('error')
      return
    }

    const unsubscribe = async () => {
      try {
        const supabase = createClient()
        const { data, error } = await supabase.rpc('unsubscribe_newsletter', {
          p_token: token,
        })

        if (error || !data?.success) {
          setErrorMsg(error?.message || t('unsubscribe.error_message'))
          setState('error')
          return
        }

        setState('success')
      } catch (err) {
        setErrorMsg(err.message || t('unsubscribe.error_message'))
        setState('error')
      }
    }

    unsubscribe()
  }, [token, t])

  return (
    <section className="min-h-[60vh] flex items-center justify-center px-6 py-16 bg-brand-bg">
      <div className="max-w-md w-full text-center">
        {/* Loading */}
        {state === 'loading' && (
          <div className="flex flex-col items-center gap-4">
            <div className="w-10 h-10 border-3 border-brand-accent/30 border-t-brand-accent rounded-full animate-spin" />
            <p className="text-gray-500">{t('unsubscribe.loading_text')}</p>
          </div>
        )}

        {/* Success */}
        {state === 'success' && (
          <div className="flex flex-col items-center gap-4">
            <div className="w-16 h-16 rounded-full bg-green-100 flex items-center justify-center">
              <svg className="w-8 h-8 text-brand-accent" fill="none" viewBox="0 0 24 24" strokeWidth="2" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" d="M4.5 12.75l6 6 9-13.5" />
              </svg>
            </div>
            <h1 className="text-2xl font-bold text-brand-deep">
              {t('unsubscribe.success_title')}
            </h1>
            <p className="text-gray-500 leading-relaxed">
              {t('unsubscribe.success_message')}
            </p>
            <p className="text-sm text-gray-400 mt-2">
              {t('unsubscribe.success_footer')}
            </p>
            <Link
              href={`/${lang}`}
              className="mt-6 inline-flex items-center gap-2 px-6 py-3 bg-brand-accent text-white rounded-xl font-semibold hover:bg-brand-accent/90 transition-colors"
            >
              {t('common.voltar_ao_site')}
            </Link>
          </div>
        )}

        {/* Error */}
        {state === 'error' && (
          <div className="flex flex-col items-center gap-4">
            <div className="w-16 h-16 rounded-full bg-red-100 flex items-center justify-center">
              <svg className="w-8 h-8 text-red-600" fill="none" viewBox="0 0 24 24" strokeWidth="2" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </div>
            <h1 className="text-2xl font-bold text-brand-deep">
              {t('unsubscribe.error_title')}
            </h1>
            <p className="text-gray-500 leading-relaxed">
              {errorMsg || t('unsubscribe.error_message')}
            </p>
            <p className="text-sm text-gray-400 mt-2">
              {t('unsubscribe.error_footer')}
            </p>
            <Link
              href={`/${lang}`}
              className="mt-6 inline-flex items-center gap-2 px-6 py-3 bg-brand-accent text-white rounded-xl font-semibold hover:bg-brand-accent/90 transition-colors"
            >
              {t('common.voltar_ao_site')}
            </Link>
          </div>
        )}
      </div>
    </section>
  )
}
