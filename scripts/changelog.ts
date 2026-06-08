#!/usr/bin/env bun

interface FileChange {
  path: string;
  added: number;
  removed: number;
}

interface ChangelogEntry {
  recorded_at: string;
  head: string;
  branch: string;
  files: FileChange[];
  totals: {
    files: number;
    added: number;
    removed: number;
  };
}

function parseNumstat(output: string): FileChange[] {
  const files: FileChange[] = [];

  for (const line of output.trim().split("\n")) {
    if (!line) continue;

    const tab = line.indexOf("\t");
    if (tab === -1) continue;

    const secondTab = line.indexOf("\t", tab + 1);
    if (secondTab === -1) continue;

    const addedRaw = line.slice(0, tab);
    const removedRaw = line.slice(tab + 1, secondTab);
    const path = line.slice(secondTab + 1);

    files.push({
      path,
      added: addedRaw === "-" ? 0 : Number(addedRaw),
      removed: removedRaw === "-" ? 0 : Number(removedRaw),
    });
  }

  return files;
}

function totals(files: FileChange[]): ChangelogEntry["totals"] {
  let added = 0;
  let removed = 0;

  for (const file of files) {
    added += file.added;
    removed += file.removed;
  }

  return { files: files.length, added, removed };
}

async function main(): Promise<void> {
  const repoRoot = (await Bun.$`git rev-parse --show-toplevel`.text()).trim();
  const numstat = await Bun.$`git diff --cached --numstat`.cwd(repoRoot).text();

  if (!numstat.trim()) {
    return;
  }

  const files = parseNumstat(numstat);
  if (files.length === 0) {
    return;
  }

  const recordedAt = new Date();
  const head = (await Bun.$`git rev-parse HEAD`.cwd(repoRoot).text()).trim();
  const branch = (await Bun.$`git rev-parse --abbrev-ref HEAD`.cwd(repoRoot).text()).trim();

  const entry: ChangelogEntry = {
    recorded_at: recordedAt.toISOString(),
    head,
    branch,
    files,
    totals: totals(files),
  };

  const ledgerDir = `${repoRoot}/ledgers/changes`;
  await Bun.$`mkdir -p ${ledgerDir}`.quiet();

  const ledgerPath = `${ledgerDir}/${recordedAt.getTime()}.json`;
  await Bun.write(ledgerPath, `${JSON.stringify(entry, null, 2)}\n`);

  const add = Bun.spawnSync(["git", "add", ledgerPath], { cwd: repoRoot });
  if (add.exitCode !== 0) {
    console.error(add.stderr.toString());
    process.exit(add.exitCode ?? 1);
  }
}

await main();