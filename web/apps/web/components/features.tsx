import { Clock, Eye, Lock, ServerOff, Smartphone, Zap } from "lucide-react";

import { SectionHeading } from "@/components/section-heading";

const features = [
  {
    icon: Lock,
    title: "Signal Protocol E2EE",
    description:
      "Industry-standard double-ratchet encryption. Only you and your contacts hold the keys.",
    featured: true,
  },
  {
    icon: Clock,
    title: "Post-seen-all deletion",
    description:
      "Once every participant has read a message, a 24-hour countdown begins — then it's gone everywhere.",
    featured: true,
  },
  {
    icon: Eye,
    title: "X-Lite UX",
    description:
      "No clutter, no feeds, no algorithm. Just conversations with the people you choose.",
    featured: false,
  },
  {
    icon: ServerOff,
    title: "Dumb relay server",
    description:
      "The relay stores and forwards encrypted envelopes. Message bodies are never decrypted server-side.",
    featured: false,
  },
  {
    icon: Smartphone,
    title: "Android-native",
    description:
      "Built with Jetpack Compose and Material 3 Expressive — fast, fluid, and designed for phones first.",
    featured: false,
  },
  {
    icon: Zap,
    title: "Moving fast",
    description:
      "Open development on GitHub with a 24-PR roadmap. We ship in public and welcome contributors.",
    featured: false,
  },
] as const;

export function Features() {
  return (
    <section id="features" className="border-t border-border bg-muted/40 px-4 py-24 sm:px-6">
      <div className="mx-auto max-w-6xl">
        <SectionHeading
          eyebrow="Features"
          title="Privacy by design, not by promise"
          description="AWChat combines proven cryptography with a retention model you can reason about — no vague “disappearing” toggles, no server-side snooping."
        />

        <div className="mt-16 grid gap-4 sm:grid-cols-2 lg:grid-cols-3 lg:gap-5">
          {features.map((feature) => (
            <article
              key={feature.title}
              className={
                feature.featured
                  ? "group relative overflow-hidden rounded-2xl border border-brand/20 bg-card p-6 shadow-sm transition-all hover:border-brand/40 hover:shadow-md lg:col-span-1"
                  : "group rounded-2xl border border-border bg-card p-6 transition-all hover:border-brand/25 hover:shadow-sm"
              }
            >
              {feature.featured ? (
                <div
                  aria-hidden
                  className="pointer-events-none absolute inset-0 bg-gradient-to-br from-brand/5 via-transparent to-teal-500/5"
                />
              ) : null}

              <div className="relative">
                <div className="mb-4 flex size-10 items-center justify-center rounded-xl bg-brand-muted text-brand transition-colors group-hover:bg-brand/15">
                  <feature.icon className="size-5" aria-hidden />
                </div>
                <h3 className="font-semibold tracking-tight">{feature.title}</h3>
                <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
                  {feature.description}
                </p>
              </div>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
