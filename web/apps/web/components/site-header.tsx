import { MessageCircle } from "lucide-react";

import { Button } from "@workspace/ui/components/button";

const GITHUB_URL = "https://github.com/awfixers-stuff/awchat";
const PATREON_URL = "https://patreon.com/awfixer";

export function SiteHeader() {
  return (
    <header className="sticky top-0 z-50 border-b border-border/60 bg-background/80 backdrop-blur-md">
      <div className="mx-auto flex h-14 max-w-6xl items-center justify-between gap-4 px-4 sm:px-6">
        <a href="#" className="flex items-center gap-2.5 font-semibold tracking-tight">
          <span className="flex size-8 items-center justify-center rounded-lg bg-primary text-primary-foreground">
            <MessageCircle className="size-4" />
          </span>
          <span>AWChat</span>
        </a>

        <nav className="hidden items-center gap-6 text-sm text-muted-foreground sm:flex">
          <a href="#features" className="transition-colors hover:text-foreground">
            Features
          </a>
          <a href="#how-it-works" className="transition-colors hover:text-foreground">
            How it works
          </a>
          <a href="#get-involved" className="transition-colors hover:text-foreground">
            Get involved
          </a>
        </nav>

        <div className="flex items-center gap-2">
          <Button variant="ghost" size="sm" asChild className="hidden sm:inline-flex">
            <a href={GITHUB_URL} target="_blank" rel="noopener noreferrer">
              GitHub
            </a>
          </Button>
          <Button size="sm" asChild>
            <a href={PATREON_URL} target="_blank" rel="noopener noreferrer">
              Patreon
            </a>
          </Button>
        </div>
      </div>
    </header>
  );
}
