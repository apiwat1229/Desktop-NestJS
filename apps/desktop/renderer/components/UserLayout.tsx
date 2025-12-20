import React from 'react';
import AnimatedBackground from './AnimatedBackground';
import Navbar from './Navbar'; // Assuming Navbar is in the same directory

interface UserLayoutProps {
  children: React.ReactNode;
}

export default function UserLayout({ children }: UserLayoutProps) {
  return (
    <div className="min-h-screen bg-background flex flex-col">
      <Navbar />

      <div className="flex flex-1 overflow-hidden relative">
        {/* Main Content - No Sidebar */}
        <main className="flex-1 overflow-y-auto bg-background/50 relative">
          <div className="absolute inset-0 pointer-events-none">
            <AnimatedBackground />
          </div>
          {children}
        </main>
      </div>
    </div>
  );
}
