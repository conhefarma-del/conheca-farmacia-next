'use client'

export default function Error({ error, reset }) {
  return (
    <div className="min-h-[60vh] flex items-center justify-center px-4">
      <div className="text-center max-w-md">
        <h2 className="font-display text-2xl font-bold text-brand-deep mb-4">
          Algo correu mal ao carregar o verificador de interações
        </h2>
        <p className="text-gray-500 dark:text-gray-400 mb-8">
          De momento não foi possível carregar as interações medicamentosas.
          Tente novamente.
        </p>
        <button onClick={reset} className="btn btn-primary">
          Tentar novamente
        </button>
      </div>
    </div>
  )
}
