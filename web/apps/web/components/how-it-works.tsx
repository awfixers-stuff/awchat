export function HowItWorks() {
  const steps = [
    {
      step: "01",
      title: "Encrypt on device",
      description:
        "Messages are sealed with libsignal before they leave your phone. Keys stay in SQLCipher-backed local storage.",
    },
    {
      step: "02",
      title: "Relay ciphertext only",
      description:
        "The Elixir relay forwards encrypted envelopes to recipients. It verifies signatures — never plaintext.",
    },
    {
      step: "03",
      title: "Read receipts trigger purge",
      description:
        "When all participants have seen a message, clients coordinate a signed purge. One day later, it's deleted for good.",
    },
  ] as const;

  return (
    <section id="how-it-works" className="px-4 py-20 sm:px-6">
      <div className="mx-auto max-w-6xl">
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="text-3xl font-semibold tracking-tight sm:text-4xl">How retention works</h2>
          <p className="mt-4 text-muted-foreground text-pretty">
            Ephemeral doesn&apos;t mean instant. AWChat uses a clear, client-computed seen-by-all
            model so everyone knows exactly when data goes away.
          </p>
        </div>

        <ol className="mt-14 grid gap-8 lg:grid-cols-3">
          {steps.map((item) => (
            <li key={item.step} className="relative">
              <span className="font-mono text-4xl font-bold text-muted-foreground/30">
                {item.step}
              </span>
              <h3 className="mt-2 text-lg font-medium">{item.title}</h3>
              <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
                {item.description}
              </p>
            </li>
          ))}
        </ol>
      </div>
    </section>
  );
}
