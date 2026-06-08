import { MessageCircle } from "lucide-react";

import { AWFIXER_URL, GITHUB_URL, NAV_LINKS, PATREON_URL } from "@/lib/constants";

export function SiteFooter() {
  const year = new Date().getFullYear();

  return (
    <footer className="border-t border-border bg-muted/30 px-4 py-14 sm:px-6">
      <div className="mx-auto max-w-6xl">
        <div className="grid gap-10 sm:grid-cols-2 lg:grid-cols-4">
          <div className="sm:col-span-2 lg:col-span-1">
            <a href="#" className="inline-flex items-center gap-2.5 font-semibold tracking-tight">
              <span className="flex size-8 items-center justify-center rounded-lg bg-primary text-primary-foreground">
                <MessageCircle className="size-4" aria-hidden />
              </span>
              AWChat
            </a>
            <p className="mt-4 max-w-xs text-sm leading-relaxed text-muted-foreground">
              Encrypted ephemeral chat with Signal Protocol E2EE and post-seen-all deletion.
            </p>
          </div>

          <div>
            <h3 className="text-sm font-semibold">Product</h3>
            <ul className="mt-4 space-y-3 text-sm text-muted-foreground">
              {NAV_LINKS.map((link) => (
                <li key={link.href}>
                  <a href={link.href} className="transition-colors hover:text-foreground">
                    {link.label}
                  </a>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h3 className="text-sm font-semibold">Resources</h3>
            <ul className="mt-4 space-y-3 text-sm text-muted-foreground">
              <li>
                <a
                  href={GITHUB_URL}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="transition-colors hover:text-foreground"
                >
                  GitHub
                </a>
              </li>
              <li>
                <a
                  href={PATREON_URL}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="transition-colors hover:text-foreground"
                >
                  Patreon
                </a>
              </li>
              <li>
                <a
                  href={AWFIXER_URL}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="transition-colors hover:text-foreground"
                >
                  awfixer.me
                </a>
              </li>
            </ul>
          </div>

          <div>
            <h3 className="text-sm font-semibold">Status</h3>
            <p className="mt-4 text-sm leading-relaxed text-muted-foreground">
              Android v1 in active development. Server relay and desktop clients are experimental.
            </p>
          </div>
        </div>

        <div className="mt-12 flex flex-col items-center justify-between gap-4 border-t border-border pt-8 text-sm text-muted-foreground sm:flex-row">
          <p>© {year} AWChat. Built by awfixer.</p>
          <p className="text-xs">Proprietary — see LICENSE.md in the repository.</p>
        </div>
      </div>
    </footer>
  );
}
