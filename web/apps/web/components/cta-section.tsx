import { GitBranch, Heart } from "lucide-react";

import { Button } from "@workspace/ui/components/button";

const GITHUB_URL = "https://github.com/awfixers-stuff/awchat";
const PATREON_URL = "https://patreon.com/awfixer";

export function CtaSection() {
  return (
    <section id="get-involved" className="border-t border-border px-4 py-20 sm:px-6">
      <div className="mx-auto max-w-6xl">
        <div className="overflow-hidden rounded-2xl border border-border bg-gradient-to-br from-emerald-500/10 via-background to-teal-500/10">
          <div className="grid gap-8 p-8 sm:p-12 lg:grid-cols-2 lg:items-center">
            <div>
              <h2 className="text-3xl font-semibold tracking-tight sm:text-4xl">Help us ship it</h2>
              <p className="mt-4 leading-relaxed text-muted-foreground text-pretty">
                AWChat is under active development — we&apos;re on PR 12 of 24 and moving quickly.
                Whether you write Kotlin, Elixir, Rust, or docs, there&apos;s room to contribute. Or
                back the project on Patreon and follow the build.
              </p>
            </div>

            <div className="flex flex-col gap-4">
              <div className="rounded-xl border border-border bg-card p-5">
                <div className="flex items-start gap-4">
                  <div className="flex size-10 shrink-0 items-center justify-center rounded-lg bg-muted">
                    <GitBranch className="size-5" />
                  </div>
                  <div className="min-w-0 flex-1">
                    <h3 className="font-medium">Contribute</h3>
                    <p className="mt-1 text-sm text-muted-foreground">
                      Open source on GitHub. We review fast and ship in public.
                    </p>
                    <Button className="mt-4" asChild>
                      <a href={GITHUB_URL} target="_blank" rel="noopener noreferrer">
                        awfixers-stuff/awchat
                      </a>
                    </Button>
                  </div>
                </div>
              </div>

              <div className="rounded-xl border border-border bg-card p-5">
                <div className="flex items-start gap-4">
                  <div className="flex size-10 shrink-0 items-center justify-center rounded-lg bg-muted">
                    <Heart className="size-5 text-rose-500" />
                  </div>
                  <div className="min-w-0 flex-1">
                    <h3 className="font-medium">Support on Patreon</h3>
                    <p className="mt-1 text-sm text-muted-foreground">
                      Fund development and get behind-the-scenes updates from awfixer.
                    </p>
                    <Button className="mt-4" variant="outline" asChild>
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
