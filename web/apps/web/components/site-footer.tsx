export function SiteFooter() {
  const year = new Date().getFullYear();

  return (
    <footer className="border-t border-border px-4 py-10 sm:px-6">
      <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-4 text-sm text-muted-foreground sm:flex-row">
        <p>© {year} AWChat. Built by awfixer.</p>
        <div className="flex items-center gap-6">
          <a
            href="https://awfixer.me"
            target="_blank"
            rel="noopener noreferrer"
            className="transition-colors hover:text-foreground"
          >
            awfixer.me
          </a>
          <a
            href="https://github.com/awfixers-stuff/awchat"
            target="_blank"
            rel="noopener noreferrer"
            className="transition-colors hover:text-foreground"
          >
            GitHub
          </a>
          <a
            href="https://patreon.com/awfixer"
            target="_blank"
            rel="noopener noreferrer"
            className="transition-colors hover:text-foreground"
          >
            Patreon
          </a>
        </div>
      </div>
    </footer>
  );
}
