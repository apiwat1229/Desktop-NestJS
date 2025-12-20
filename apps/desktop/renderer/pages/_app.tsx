import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import type { AppProps } from 'next/app';
import { Toaster } from '../components/ui/toaster';
import { SettingsProvider } from '../contexts/SettingsContext';
import '../i18n/config'; // Initialize i18n (Reload Triggered)
import '../styles/globals.css';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
});

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <>
      <SettingsProvider>
        <QueryClientProvider client={queryClient}>
          <Component {...pageProps} />
        </QueryClientProvider>
      </SettingsProvider>
      <Toaster />
    </>
  );
}

export default MyApp;
