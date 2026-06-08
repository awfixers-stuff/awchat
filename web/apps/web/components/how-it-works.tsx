import { Clock, Lock, Server } from "lucide-react";

import { SectionHeading } from "@/components/section-heading";

const steps = [
  {
    step: "01",
    icon: Lock,
    title: "Encrypt on device",
    description:
      "Messages are sealed with libsignal before they leave your phone. Keys stay in SQLCipher-backed local storage.",
  },
  {
    step: "02",
    icon: Server,
    title: "Relay ciphertext only",
    description:
      "The Elixir relay forwards encrypted envelopes to recipients. It verifies signatures — never plaintext.",
  },
  {
    step: "03",
    icon: Clock,
    title: "Read receipts trigger purge",
    description:
      "When all participants have seen a message, clients coordinate a signed purge. One day later, it's deleted for good.",
  },
] as const;

export function HowItWorks() {
  return (
    <section id="how-it-works" className="px-4 py-24 sm:px-6">
      <div className="mx-auto max-w-6xl">
        <SectionHeading
          eyebrow="How it works"
          title="How retention works"
          description="Ephemeral doesn't mean instant. AWChat uses a clear, client-computed seen-by-all model so everyone knows exactly when data goes away."
        />

        <ol className="relative mt-16 grid gap-6 lg:grid-cols-3 lg:gap-8">
          <div
            aria-hidden
            className="absolute top-12 right-[16.67%] left-[16.67%] hidden h-px bg-gradient-to-r from-transparent via-border to-transparent lg:block"
          />

          {steps.map((item, index) => (
            <li
              key={item.step}
              className="relative rounded-2xl border border-border bg-card p-6 transition-colors hover:border-brand/25"
            >
              <div className="mb-5 flex items-center justify-between">
                <div className="flex size-10 items-center justify-center rounded-xl bg-brand-muted text-brand">
                  <item.icon className="size-5" aria-hidden />
                </div>
                <span className="font-mono text-sm font-semibold text-muted-foreground/50">
                  {item.step}
                </span>
              </div>

              <h3 className="text-lg font-semibold tracking-tight">{item.title}</h3>
              <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
                {item.description}
              </p>

              {index < steps.length - 1 ? (
                <div aria-hidden className="mx-auto mt-6 h-8 w-px bg-border lg:hidden" />
              ) : null}
            </li>
          ))}
        </ol>
      </div>
    </section>
  );
}
