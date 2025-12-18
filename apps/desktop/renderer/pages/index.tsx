import Link from 'next/link';

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 to-slate-800">
      <div className="container mx-auto px-4 py-16">
        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-6xl font-bold text-white mb-6">
            Welcome to My App
          </h1>
          <p className="text-xl text-slate-300 mb-12">
            A modern desktop application built with Nextron, NestJS, and PostgreSQL
          </p>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-12">
            <div className="bg-white/10 backdrop-blur-lg rounded-lg p-8 border border-white/20">
              <h2 className="text-2xl font-semibold text-white mb-4">
                Frontend
              </h2>
              <ul className="text-slate-300 space-y-2 text-left">
                <li>✓ Next.js 14</li>
                <li>✓ Electron</li>
                <li>✓ Shadcn/UI</li>
                <li>✓ Tailwind CSS</li>
                <li>✓ React Query</li>
              </ul>
            </div>

            <div className="bg-white/10 backdrop-blur-lg rounded-lg p-8 border border-white/20">
              <h2 className="text-2xl font-semibold text-white mb-4">
                Backend
              </h2>
              <ul className="text-slate-300 space-y-2 text-left">
                <li>✓ NestJS</li>
                <li>✓ Prisma ORM</li>
                <li>✓ PostgreSQL</li>
                <li>✓ JWT Auth</li>
                <li>✓ TypeScript</li>
              </ul>
            </div>
          </div>

          <div className="flex gap-4 justify-center">
            <Link
              href="/login"
              className="px-8 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-semibold transition-colors"
            >
              Get Started
            </Link>
            <Link
              href="/posts"
              className="px-8 py-3 bg-white/10 hover:bg-white/20 text-white rounded-lg font-semibold transition-colors border border-white/20"
            >
              View Posts
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
