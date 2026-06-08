import { GitBranch, Heart, Users } from "lucide-react";

import { Button } from "@workspace/ui/components/button";
import { SectionHeading } from "@/components/section-heading";
import { GITHUB_URL, PATREON_URL } from "@/lib/constants";

export function CtaSection() {
  return (
    <section id="get-involved" className="border-t border-border px-4 py-24 sm:px-6">
      <div className="mx-auto max-w-6xl">
        <div className="overflow-hidden rounded-3xl border border-border bg-gradient-to-br from-brand/8 via-card to-teal-500/8">
          <div className="grid gap-10 p-8 sm:p-12 lg:grid-cols-2 lg:items-center lg:gap-16">
            <div>
              <SectionHeading
                eyebrow="Get involved"
                title="Help us ship it"
                description="AWChat is under active development — we're on PR 12 of 24 and moving quickly. Whether you write Kotlin, Elixir, Rust, or docs, there's room to contribute. Or back the project on Patreon and follow the build."
                align="left"
              />

              <div className="mt-8 flex items-center gap-6 text-sm text-muted-foreground">
                <div className="flex items-center gap-2">
                  <Users className="size-4 text-brand" aria-hidden />
                  Open source
                </div>
                <div className="flex items-center gap-2">
                  <GitBranch className="size-4 text-brand" aria-hidden />
                  24-PR roadmap
                </div>
              </div>
            </div>

            <div className="flex flex-col gap-4">
              <div className="rounded-2xl border border-border bg-background/80 p-6 backdrop-blur-sm">
                <div className="flex items-start gap-4">
                  <div className="flex size-11 shrink-0 items-center justify-center rounded-xl bg-brand-muted text-brand">
                    <GitBranch className="size-5" aria-hidden />
                  </div>
                  <div className="min-w-0 flex-1">
                    <h3 className="font-semibold tracking-tight">Contribute</h3>
                    <p className="mt-1.5 text-sm leading-relaxed text-muted-foreground">
                      Open source on GitHub. We review fast and ship in public.
                    </p>
                    <Button className="mt-5" asChild>
                      <a href={GITHUB_URL} target="_blank" rel="noopener noreferrer">
                        awfixers-stuff/awchat
                      </a>
                    </Button>
                  </div>
                </div>
              </div>

              <div className="rounded-2xl border border-border bg-background/80 p-6 backdrop-blur-sm">
                <div className="flex items-start gap-4">
                  <div className="flex size-11 shrink-0 items-center justify-center rounded-xl bg-rose-500/10 text-rose-600 dark:text-rose-400">
                    <Heart className="size-5" aria-hidden />
                  </div>
                  <div className="min-w-0 flex-1">
                    <h3 className="font-semibold tracking-tight">Support on Patreon</h3>
                    <p className="mt-1.5 text-sm leading-relaxed text-muted-foreground">
                      Fund development and get behind-the-scenes updates from awfixer.
                    </p>
                    <Button className="mt-5" variant="outline" asChild>
                      <a href={PATREON_URL} target="_blank" rel="noopener noreferrer">
                        patreon.com/awfixer
                      </a>
                    </Button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
