#!/usr/bin/env bun
/** Mark agent-queue as delivered so pi/omp do not re-send the same follow-up on the next agent_end. */
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { join } from "node:path";
import { $ } from "bun";

const root = (await $`git rev-parse --show-toplevel`.quiet().text()).trim();
const queuePath = join(root, "ledgers/coderabbit/agent-queue.json");

let raw: string;
try {
  raw = await readFile(queuePath, "utf8");
} catch {
  process.exit(0);
}

const queue = JSON.parse(raw) as Record<string, unknown>;
await mkdir(join(root, "ledgers/coderabbit"), { recursive: true });
await writeFile(
  queuePath,
  `${JSON.stringify({ ...queue, version: 1, pending: false }, null, 2)}\n`,
);
