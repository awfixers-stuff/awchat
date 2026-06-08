import { CtaSection } from "@/components/cta-section";
import { DevBanner } from "@/components/dev-banner";
import { Features } from "@/components/features";
import { Hero } from "@/components/hero";
import { HowItWorks } from "@/components/how-it-works";
import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";

export default function Page() {
  return (
    <div className="flex min-h-svh flex-col">
      <DevBanner />
      <SiteHeader />
      <main className="flex-1">
        <Hero />
        <Features />
        <HowItWorks />
        <CtaSection />
      </main>
      <SiteFooter />
    </div>
  );
}
