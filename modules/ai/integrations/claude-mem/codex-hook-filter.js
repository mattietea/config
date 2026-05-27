let input = "";

process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => {
  input += chunk;
});
process.stdin.on("end", () => {
  const trimmed = input.trim();
  if (!trimmed) {
    process.exit(0);
  }

  try {
    const output = JSON.parse(trimmed);
    if (output && typeof output === "object" && !Array.isArray(output)) {
      delete output.suppressOutput;
      delete output.status;
      delete output.message;
      process.stdout.write(JSON.stringify(output));
      process.exit(0);
    }
  } catch {
    // Preserve non-JSON output so real hook failures still surface.
  }

  process.stdout.write(input);
});
