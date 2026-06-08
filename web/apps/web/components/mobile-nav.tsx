"use client";

import { Menu, X } from "lucide-react";
import * as React from "react";

import { Button } from "@workspace/ui/components/button";
import { GITHUB_URL, NAV_LINKS, PATREON_URL } from "@/lib/constants";
import { cn } from "@workspace/ui/lib/utils";

import { ThemeToggle } from "./theme-toggle";

export function MobileNav() {
  const [open, setOpen] = React.useState(false);

  React.useEffect(() => {
    if (!open) {
      return;
    }

    function onKeyDown(event: KeyboardEvent) {
      if (event.key === "Escape") {
        setOpen(false);
      }
    }

    document.body.style.overflow = "hidden";
    window.addEventListener("keydown", onKeyDown);

    return () => {
      document.body.style.overflow = "";
      window.removeEventListener("keydown", onKeyDown);
    };
  }, [open]);

  return (
    <div className="sm:hidden">
      <Button
        variant="ghost"
        size="icon-sm"
        onClick={() => setOpen((value) => !value)}
        aria-expanded={open}
        aria-controls="mobile-nav-panel"
        aria-label={open ? "Close menu" : "Open menu"}
      >
        {open ? <X className="size-5" /> : <Menu className="size-5" />}
      </Button>

      <div
        className={cn(
          "fixed inset-0 z-40 bg-background/80 backdrop-blur-sm transition-opacity",
          open ? "opacity-100" : "pointer-events-none opacity-0",
        )}
        aria-hidden={!open}
        onClick={() => setOpen(false)}
      />

      <nav
        id="mobile-nav-panel"
        className={cn(
          "fixed inset-x-0 top-14 z-50 border-b border-border bg-background/95 backdrop-blur-md transition-transform duration-200 ease-out",
          open ? "translate-y-0" : "-translate-y-2 pointer-events-none opacity-0",
        )}
        aria-hidden={!open}
      >
        <div className="mx-auto flex max-w-6xl flex-col gap-1 px-4 py-4">
          {NAV_LINKS.map((link) => (
            <a
              key={link.href}
              href={link.href}
              onClick={() => setOpen(false)}
              className="rounded-lg px-3 py-2.5 text-sm font-medium text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
            >
              {link.label}
            </a>
          ))}

          <div className="mt-3 flex items-center gap-2 border-t border-border pt-4">
            <ThemeToggle />
            <Button variant="outline" size="sm" className="flex-1" asChild>
              <a href={GITHUB_URL} target="_blank" rel="noopener noreferrer">
                GitHub
              </a>
            </Button>
            <Button size="sm" className="flex-1" asChild>
              <a href={PATREON_URL} target="_blank" rel="noopener noreferrer">
                Patreon
              </a>
            </Button>
          </div>
        </div>
      </nav>
    </div>
  );
}
