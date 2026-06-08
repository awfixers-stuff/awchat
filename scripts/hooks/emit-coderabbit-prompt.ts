#!/usr/bin/env bun
import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { $ } from "bun";

const root = (await $`git rev-parse --show-toplevel`.quiet().text()).trim();
const queuePath = join(root, "ledgers/coderabbit/agent-queue.json");

interface AgentQueue {
  pending?: boolean;
  agentPrompt?: string;
}

let raw: string;
try {
  raw = await readFile(queuePath, "utf8");
} catch {
  process.exit(0);
}

const queue = JSON.parse(raw) as AgentQueue;
if (!queue.pending || !queue.agentPrompt?.trim()) {
  process.exit(0);
}

// Markers let omp/pi hooks detect when to call sendUserMessage
process.stdout.write(
  `\n__AWCHAT_CODERABBIT_PROMPT_START__\n${queue.agentPrompt}\n__AWCHAT_CODERABBIT_PROMPT_END__\n`,
);
