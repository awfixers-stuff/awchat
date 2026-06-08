import { MessageCircle } from "lucide-react";

import { Button } from "@workspace/ui/components/button";
import { GITHUB_URL, NAV_LINKS, PATREON_URL } from "@/lib/constants";

import { MobileNav } from "./mobile-nav";
import { ThemeToggle } from "./theme-toggle";

export function SiteHeader() {
  return (
    <header className="sticky top-0 z-50 border-b border-border/60 bg-background/80 backdrop-blur-md supports-[backdrop-filter]:bg-background/70">
      <div className="mx-auto flex h-14 max-w-6xl items-center justify-between gap-4 px-4 sm:px-6">
        <a
          href="#"
          className="flex items-center gap-2.5 font-semibold tracking-tight transition-opacity hover:opacity-80"
        >
          <span className="flex size-8 items-center justify-center rounded-lg bg-primary text-primary-foreground shadow-sm shadow-primary/20">
            <MessageCircle className="size-4" aria-hidden />
          </span>
          <span>AWChat</span>
        </a>

        <nav className="hidden items-center gap-1 text-sm sm:flex" aria-label="Primary navigation">
          {NAV_LINKS.map((link) => (
            <a
              key={link.href}
              href={link.href}
              className="rounded-md px-3 py-1.5 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
            >
              {link.label}
            </a>
          ))}
        </nav>

        <div className="flex items-center gap-1">
          <ThemeToggle className="hidden sm:inline-flex" />
          <Button variant="ghost" size="sm" asChild className="hidden md:inline-flex">
            <a href={GITHUB_URL} target="_blank" rel="noopener noreferrer">
              GitHub
            </a>
          </Button>
          <Button size="sm" asChild className="hidden sm:inline-flex">
            <a href={PATREON_URL} target="_blank" rel="noopener noreferrer">
              Patreon
            </a>
          </Button>
          <MobileNav />
        </div>
      </div>
    </header>
  );
}
