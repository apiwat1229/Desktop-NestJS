import Link from 'next/link';
import AnimatedBackground from '../components/AnimatedBackground';
import Navbar from '../components/Navbar';

export default function Custom404() {
  return (
    <div className="min-h-screen bg-background flex flex-col font-sans">
      <Navbar />

      <div className="flex-1 flex flex-col items-center justify-center relative overflow-hidden">
        <div className="absolute inset-0 opacity-20 pointer-events-none">
          <AnimatedBackground />
        </div>

        <div className="z-10 text-center space-y-6 px-4">
          <div className="flex items-center justify-center gap-4">
            <h1 className="text-7xl font-bold tracking-tighter text-foreground">404</h1>
            <div className="h-16 w-px bg-border"></div>
            <div className="text-left">
              <h2 className="text-2xl font-semibold text-foreground">Page not found</h2>
              <p className="text-muted-foreground">The page you are looking for does not exist.</p>
            </div>
          </div>

          <div className="pt-8">
            <Link
              href="/posts"
              className="inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 bg-primary text-primary-foreground shadow hover:bg-primary/90 h-10 px-8"
            >
              Go back home
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
