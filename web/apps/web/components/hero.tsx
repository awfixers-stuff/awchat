import { ArrowRight, Shield } from "lucide-react";

import { Button } from "@workspace/ui/components/button";

const GITHUB_URL = "https://github.com/awfixers-stuff/awchat";
const PATREON_URL = "https://patreon.com/awfixer";

export function Hero() {
  return (
    <section className="relative overflow-hidden px-4 pb-20 pt-16 sm:px-6 sm:pt-24 lg:pb-28">
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0 -z-10 bg-[radial-gradient(ellipse_80%_60%_at_50%_-20%,oklch(0.55_0.15_250/0.18),transparent)] dark:bg-[radial-gradient(ellipse_80%_60%_at_50%_-20%,oklch(0.45_0.12_250/0.25),transparent)]"
      />

      <div className="mx-auto max-w-6xl">
        <div className="mx-auto max-w-3xl text-center">
          <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-border bg-muted/50 px-3 py-1 text-xs font-medium text-muted-foreground">
            <Shield className="size-3.5 text-emerald-600 dark:text-emerald-400" />
            Signal Protocol end-to-end encryption
          </div>

          <h1 className="text-4xl font-semibold tracking-tight text-balance sm:text-5xl lg:text-6xl">
            Encrypted chat that{" "}
            <span className="bg-gradient-to-r from-emerald-600 to-teal-500 bg-clip-text text-transparent dark:from-emerald-400 dark:to-teal-300">
              actually disappears
            </span>
          </h1>

          <p className="mx-auto mt-6 max-w-2xl text-lg leading-relaxed text-muted-foreground text-pretty">
            AWChat is a mobile-first messenger with X-Lite simplicity, Material 3 Expressive design,
            and messages that purge one day after everyone has seen them. The server relays
            ciphertext — it never reads your conversations.
          </p>

          <div className="mt-10 flex flex-col items-center justify-center gap-3 sm:flex-row">
            <Button size="lg" asChild>
              <a href={GITHUB_URL} target="_blank" rel="noopener noreferrer">
                Contribute on GitHub
                <ArrowRight />
              </a>
            </Button>
            <Button size="lg" variant="outline" asChild>
              <a href={PATREON_URL} target="_blank" rel="noopener noreferrer">
                Join on Patreon
              </a>
            </Button>
          </div>

          <p className="mt-6 text-sm text-muted-foreground">
            Android is the official v1 target. Linux desktop and TUI clients are experimental.
          </p>
        </div>

        <div className="mx-auto mt-16 max-w-lg">
          <div className="rounded-2xl border border-border bg-card p-1 shadow-xl shadow-black/5 dark:shadow-black/30">
            <div className="rounded-xl bg-muted/40 p-6">
              <div className="mb-4 flex items-center gap-3">
                <div className="size-10 rounded-full bg-gradient-to-br from-emerald-500 to-teal-600" />
                <div>
                  <p className="text-sm font-medium">Direct message</p>
                  <p className="text-xs text-muted-foreground">Seen by all · purges in 24h</p>
                </div>
              </div>
              <div className="space-y-3">
                <div className="ml-auto max-w-[85%] rounded-2xl rounded-tr-sm bg-primary px-4 py-2.5 text-sm text-primary-foreground">
                  Meet tomorrow at the usual spot?
                </div>
                <div className="max-w-[85%] rounded-2xl rounded-tl-sm border border-border bg-background px-4 py-2.5 text-sm">
                  Sounds good. This thread deletes after we both read it.
                </div>
                <div className="flex items-center justify-center gap-1.5 pt-2 text-xs text-muted-foreground">
                  <span className="size-1.5 rounded-full bg-emerald-500" />
                  End-to-end encrypted
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
