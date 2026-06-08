import { Construction } from "lucide-react";

export function DevBanner() {
  return (
    <div className="border-b border-amber-500/20 bg-amber-500/10">
      <div className="mx-auto flex max-w-6xl items-center justify-center gap-2 px-4 py-2.5 text-center text-sm text-amber-950 dark:text-amber-100">
        <Construction className="size-4 shrink-0 text-amber-600 dark:text-amber-400" />
        <p>
          <span className="font-medium">In active development.</span> Features ship fast —
          contribute on GitHub or support the build on Patreon.
        </p>
      </div>
    </div>
  );
}
