import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";

import "@workspace/ui/globals.css";
import { ThemeProvider } from "@/components/theme-provider";
import { cn } from "@workspace/ui/lib/utils";

const geist = Geist({ subsets: ["latin"], variable: "--font-sans" });

const fontMono = Geist_Mono({
  subsets: ["latin"],
  variable: "--font-mono",
});

export const metadata: Metadata = {
  title: "AWChat — Encrypted ephemeral chat",
  description:
    "Mobile-first encrypted messenger with Signal Protocol E2EE and post-seen-all deletion. In active development — contribute or support on Patreon.",
  openGraph: {
    title: "AWChat — Encrypted ephemeral chat",
    description:
      "Signal Protocol E2EE, X-Lite UX, and messages that purge after everyone has seen them.",
    type: "website",
    siteName: "AWChat",
  },
  twitter: {
    card: "summary_large_image",
    title: "AWChat — Encrypted ephemeral chat",
    description:
      "Signal Protocol E2EE, X-Lite UX, and messages that purge after everyone has seen them.",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      suppressHydrationWarning
      className={cn("antialiased", fontMono.variable, "font-sans", geist.variable)}
    >
      <body>
        <a
          href="#main-content"
          className="sr-only focus:not-sr-only focus:absolute focus:left-4 focus:top-4 focus:z-[100] focus:rounded-lg focus:bg-primary focus:px-4 focus:py-2 focus:text-sm focus:font-medium focus:text-primary-foreground"
        >
          Skip to main content
        </a>
        <ThemeProvider>{children}</ThemeProvider>
      </body>
    </html>
  );
}
