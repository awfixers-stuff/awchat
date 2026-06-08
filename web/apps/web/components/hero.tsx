import { ArrowRight, Lock, Shield, Timer, Zap } from "lucide-react";

import { Button } from "@workspace/ui/components/button";
import { GITHUB_URL, PATREON_URL } from "@/lib/constants";

const trustSignals = [
  { icon: Shield, label: "Signal Protocol" },
  { icon: Lock, label: "Zero server decryption" },
  { icon: Timer, label: "24h post-seen purge" },
] as const;

export function Hero() {
  return (
    <section className="relative overflow-hidden px-4 pb-24 pt-16 sm:px-6 sm:pt-20 lg:pb-32 lg:pt-24">
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0 -z-10 bg-[radial-gradient(ellipse_80%_50%_at_50%_-10%,oklch(0.52_0.14_162/0.12),transparent)] dark:bg-[radial-gradient(ellipse_80%_50%_at_50%_-10%,oklch(0.68_0.14_162/0.18),transparent)]"
      />
      <div
        aria-hidden
        className="pointer-events-none absolute inset-0 -z-10 bg-[linear-gradient(to_right,oklch(0.5_0_0/0.03)_1px,transparent_1px),linear-gradient(to_bottom,oklch(0.5_0_0/0.03)_1px,transparent_1px)] bg-[size:4rem_4rem] [mask-image:radial-gradient(ellipse_70%_60%_at_50%_0%,#000_70%,transparent_100%)]"
      />

      <div className="mx-auto grid max-w-6xl items-center gap-16 lg:grid-cols-2 lg:gap-12">
        <div className="max-w-xl lg:max-w-none">
          <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-brand/20 bg-brand-muted/50 px-3 py-1 text-xs font-medium text-brand">
            <Shield className="size-3.5" aria-hidden />
            End-to-end encrypted by default
          </div>

          <h1 className="text-4xl font-semibold tracking-tight text-balance sm:text-5xl lg:text-[3.25rem] lg:leading-[1.1]">
            Encrypted chat that{" "}
            <span className="bg-gradient-to-r from-brand to-teal-500 bg-clip-text text-transparent">
              actually disappears
            </span>
          </h1>

          <p className="mt-6 text-lg leading-relaxed text-muted-foreground text-pretty">
            AWChat is a mobile-first messenger with X-Lite simplicity and messages that purge one
            day after everyone has seen them. The server relays ciphertext — it never reads your
            conversations.
          </p>

          <div className="mt-10 flex flex-col gap-3 sm:flex-row sm:items-center">
            <Button size="lg" asChild>
              <a href={GITHUB_URL} target="_blank" rel="noopener noreferrer">
                Contribute on GitHub
                <ArrowRight aria-hidden />
              </a>
            </Button>
            <Button size="lg" variant="outline" asChild>
              <a href={PATREON_URL} target="_blank" rel="noopener noreferrer">
                Join on Patreon
              </a>
            </Button>
          </div>

          <p className="mt-5 text-sm text-muted-foreground">
            Android is the official v1 target. Linux desktop and TUI clients are experimental.
          </p>

          <ul className="mt-10 flex flex-wrap gap-x-6 gap-y-3 border-t border-border pt-8">
            {trustSignals.map((signal) => (
              <li
                key={signal.label}
                className="flex items-center gap-2 text-sm text-muted-foreground"
              >
                <signal.icon className="size-4 text-brand" aria-hidden />
                {signal.label}
              </li>
            ))}
          </ul>
        </div>

        <div className="relative mx-auto w-full max-w-md lg:max-w-none">
          <div
            aria-hidden
            className="absolute -inset-4 rounded-3xl bg-gradient-to-br from-brand/10 via-transparent to-teal-500/10 blur-2xl"
          />

          <div className="relative rounded-2xl border border-border bg-card p-1.5 shadow-2xl shadow-black/8 dark:shadow-black/40">
            <div className="flex items-center gap-2 border-b border-border px-4 py-3">
              <div className="flex gap-1.5" aria-hidden>
                <span className="size-2.5 rounded-full bg-red-400/80" />
                <span className="size-2.5 rounded-full bg-amber-400/80" />
                <span className="size-2.5 rounded-full bg-emerald-400/80" />
              </div>
              <span className="mx-auto text-xs font-medium text-muted-foreground">
                AWChat · Direct message
              </span>
            </div>

            <div className="p-5 sm:p-6">
              <div className="mb-5 flex items-center gap-3">
                <div className="flex size-10 items-center justify-center rounded-full bg-gradient-to-br from-brand to-teal-600 text-sm font-semibold text-white">
                  A
                </div>
                <div>
                  <p className="text-sm font-medium">Alex</p>
                  <p className="flex items-center gap-1.5 text-xs text-muted-foreground">
                    <span className="size-1.5 rounded-full bg-brand" aria-hidden />
                    Seen by all · purges in 24h
                  </p>
                </div>
              </div>

              <div className="space-y-3">
                <div className="ml-auto max-w-[85%] rounded-2xl rounded-tr-sm bg-primary px-4 py-2.5 text-sm text-primary-foreground shadow-sm">
                  Meet tomorrow at the usual spot?
                </div>
                <div className="max-w-[85%] rounded-2xl rounded-tl-sm border border-border bg-muted/50 px-4 py-2.5 text-sm">
                  Sounds good. This thread deletes after we both read it.
                </div>
              </div>

              <div className="mt-5 flex items-center justify-center gap-1.5 rounded-lg bg-brand-muted/40 py-2 text-xs font-medium text-brand">
                <Zap className="size-3" aria-hidden />
                End-to-end encrypted
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
