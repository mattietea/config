const fs = require("fs");

const [hooksFile, filter, node] = process.argv.slice(2);
const marker = "codex-hook-filter.js";

function shellQuote(value) {
  const sq = String.fromCharCode(39);
  return (
    sq +
    String(value).replace(new RegExp(sq, "g"), sq + '"' + sq + '"' + sq) +
    sq
  );
}

function wrap(command) {
  if (command.includes(marker)) {
    return command;
  }

  return [
    "_CLAUDE_MEM_CODEX_HOOK_OUT=$(mktemp)",
    "( " + command + ' ) >"$_CLAUDE_MEM_CODEX_HOOK_OUT"',
    "_CLAUDE_MEM_CODEX_HOOK_STATUS=$?",
    shellQuote(node) +
      " " +
      shellQuote(filter) +
      ' <"$_CLAUDE_MEM_CODEX_HOOK_OUT"',
    'rm -f "$_CLAUDE_MEM_CODEX_HOOK_OUT"',
    'exit "$_CLAUDE_MEM_CODEX_HOOK_STATUS"',
  ].join("; ");
}

function visit(value) {
  if (Array.isArray(value)) {
    value.forEach(visit);
    return;
  }

  if (!value || typeof value !== "object") {
    return;
  }

  if (value.type === "command" && typeof value.command === "string") {
    value.command = wrap(value.command);
  }

  Object.values(value).forEach(visit);
}

const hooks = JSON.parse(fs.readFileSync(hooksFile, "utf8"));
visit(hooks);
fs.writeFileSync(hooksFile, JSON.stringify(hooks, null, 2) + "\n");
