import { Clock, Eye, Lock, ServerOff, Smartphone, Zap } from "lucide-react";

const features = [
  {
    icon: Lock,
    title: "Signal Protocol E2EE",
    description:
      "Industry-standard double-ratchet encryption. Only you and your contacts hold the keys.",
  },
  {
    icon: Clock,
    title: "Post-seen-all deletion",
    description:
      "Once every participant has read a message, a 24-hour countdown begins — then it's gone everywhere.",
  },
  {
    icon: Eye,
    title: "X-Lite UX",
    description:
      "No clutter, no feeds, no algorithm. Just conversations with the people you choose.",
  },
  {
    icon: ServerOff,
    title: "Dumb relay server",
    description:
      "The relay stores and forwards encrypted envelopes. Message bodies are never decrypted server-side.",
  },
  {
    icon: Smartphone,
    title: "Android-native",
    description:
      "Built with Jetpack Compose and Material 3 Expressive — fast, fluid, and designed for phones first.",
  },
  {
    icon: Zap,
    title: "Moving fast",
    description:
      "Open development on GitHub with a 24-PR roadmap. We ship in public and welcome contributors.",
  },
] as const;

export function Features() {
  return (
    <section id="features" className="border-t border-border bg-muted/30 px-4 py-20 sm:px-6">
      <div className="mx-auto max-w-6xl">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="text-3xl font-semibold tracking-tight sm:text-4xl">
            Privacy by design, not by promise
          </h2>
          <p className="mt-4 text-muted-foreground text-pretty">
            AWChat combines proven cryptography with a retention model you can reason about — no
            vague &ldquo;disappearing&rdquo; toggles, no server-side snooping.
          </p>
        </div>

        <div className="mt-14 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {features.map((feature) => (
            <article
              key={feature.title}
              className="rounded-xl border border-border bg-card p-6 transition-colors hover:border-emerald-500/30"
            >
              <div className="mb-4 flex size-10 items-center justify-center rounded-lg bg-emerald-500/10 text-emerald-600 dark:text-emerald-400">
                <feature.icon className="size-5" />
              </div>
              <h3 className="font-medium">{feature.title}</h3>
              <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
                {feature.description}
              </p>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
