/**
 * oh-my-pi (omp) turn gate: CodeRabbit review + follow-up prompt.
 *
 * Auto-discovered from `.omp/hooks/post/*.ts` when cwd is this repo.
 */
import { spawn } from "node:child_process";
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

function runTurnHook(root: string): Promise<{ stdout: string; code: number | null }> {
  const hook = join(root, "scripts/hooks/agent-turn-coderabbit");
  return new Promise((resolve, reject) => {
    const proc = spawn("sh", [hook], {
      cwd: root,
      stdio: ["ignore", "pipe", "inherit"],
    });
    let stdout = "";
    proc.stdout?.on("data", (chunk: Buffer | string) => {
      stdout += chunk.toString();
    });
    proc.on("error", reject);
    proc.on("close", (code) => resolve({ stdout, code }));
  });
}

export default function (pi: HookAPI) {
  pi.on("agent_end", async (_event, ctx) => {
    const root = ctx.cwd;
    try {
      const { stdout } = await runTurnHook(root);
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