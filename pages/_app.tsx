import "../styles/globals.scss";
import { useEffect } from "react";
import Link from "next/link";
import type { AppProps } from "next/app";
import { MoralisProvider } from "react-moralis";

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <MoralisProvider
      appId={process.env.NEXT_PUBLIC_APPLICATION_ID!}
      serverUrl={process.env.NEXT_PUBLIC_SERVER_URL!}
    >
      <div>
        <nav className="border-b p-6">
          <p className="text-4xl font-bold">NFT-Marketplace</p>
          <div className="flex mt-4">
            <Link href="/">
              <a className="mr-4 text-pink-500">Home</a>
            </Link>
            <Link href="/create-item">
              <a className="mr-6 text-pink-500">Sell Digital Asset</a>
            </Link>
            <Link href="/my-assets">
              <a className="mr-6 text-pink-500">My Digital Assets</a>
            </Link>
            <Link href="/creator-dashboard">
              <a className="mr-6 text-pink-500">Creator Dashboard</a>
            </Link>
          </div>
        </nav>
        <Component {...pageProps} />
      </div>
    </MoralisProvider>
  );
}
export default MyApp;
