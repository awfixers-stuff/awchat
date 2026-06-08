/**
 * oh-my-pi (omp) turn gate: CodeRabbit review + follow-up prompt.
 *
 * Auto-discovered from `.omp/hooks/post/*.ts` when cwd is this repo.
 */
import { join } from "node:path";
import type { HookAPI } from "@agent/coding-agent";

const PROMPT_START = "__AWCHAT_CODERABBIT_PROMPT_START__";
const PROMPT_END = "__AWCHAT_CODERABBIT_PROMPT_END__";

function extractPrompt(stdout: string): string | null {
  const start = stdout.indexOf(PROMPT_START);
  const end = stdout.indexOf(PROMPT_END);
  if (start === -1 || end === -1 || end <= start) return null;
  return stdout.slice(start + PROMPT_START.length, end).trim();
}

export default function (pi: HookAPI) {
  pi.on("agent_end", async (_event, ctx) => {
    const root = ctx.cwd;
    const hook = join(root, "scripts/hooks/agent-turn-coderabbit");
    try {
      const proc = Bun.spawn(["sh", hook], {
        cwd: root,
        stdout: "pipe",
        stderr: "inherit",
      });
      const stdout = await new Response(proc.stdout).text();
      await proc.exited;

      const prompt = extractPrompt(stdout);
      if (!prompt) return;

      pi.sendMessage(
        {
          customType: "coderabbit-turn-gate",
          content: prompt,
          display: false,
        },
        { triggerTurn: true, deliverAs: "followUp" },
      );
      ctx.ui.notify("CodeRabbit: queued fixes for critical/major findings", "info");
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      ctx.ui.notify(`CodeRabbit turn hook failed: ${message}`, "warning");
    }
  });
}
