import { Construction } from "lucide-react";

import { GITHUB_URL, PATREON_URL } from "@/lib/constants";

export function DevBanner() {
  return (
    <div role="status" className="border-b border-amber-500/20 bg-amber-500/8 dark:bg-amber-500/10">
      <div className="mx-auto flex max-w-6xl items-center justify-center gap-2 px-4 py-2.5 text-center text-sm text-amber-950 dark:text-amber-100">
        <Construction className="size-4 shrink-0 text-amber-600 dark:text-amber-400" aria-hidden />
        <p>
          <span className="font-medium">In active development.</span>{" "}
          <a
            href={GITHUB_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="underline decoration-amber-600/40 underline-offset-2 transition-colors hover:text-amber-800 dark:hover:text-amber-50"
          >
            Contribute on GitHub
          </a>{" "}
          or{" "}
          <a
            href={PATREON_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="underline decoration-amber-600/40 underline-offset-2 transition-colors hover:text-amber-800 dark:hover:text-amber-50"
          >
            support on Patreon
          </a>
          .
        </p>
      </div>
    </div>
  );
}
