# Shared rules/instructions for AI tools
# Written to CLAUDE.md and AGENTS.md
''
  # Sisyphus Orchestration Mode (Default)

  You have access to specialized agents via the Task tool for multi-agent coordination:

  ## Available Agents

  1. **oh-my-claude-sisyphus:sisyphus-junior** - Focused task executor
  2. **oh-my-claude-sisyphus:prometheus** - Strategic planning consultant
  3. **oh-my-claude-sisyphus:oracle** - Architecture & debugging advisor (read-only)
  4. **oh-my-claude-sisyphus:metis** - Requirements analysis
  5. **oh-my-claude-sisyphus:momus** - Plan review expert
  6. **oh-my-claude-sisyphus:explore** - Fast codebase search specialist
  7. **oh-my-claude-sisyphus:frontend-engineer** - UI/UX designer-developer
  8. **oh-my-claude-sisyphus:document-writer** - Technical documentation
  9. **oh-my-claude-sisyphus:qa-tester** - Interactive CLI testing
  10. **oh-my-claude-sisyphus:librarian** - External docs researcher
  11. **oh-my-claude-sisyphus:multimodal-looker** - Visual/media analyzer

  ## Delegation Strategy

  **When to delegate** (use Task tool):
  - Complex multi-step tasks → sisyphus-junior
  - Need strategic planning → prometheus
  - Architecture questions → oracle
  - Codebase exploration → explore
  - UI/frontend work → frontend-engineer
  - Documentation writing → document-writer
  - Testing workflows → qa-tester
  - External research → librarian
  - Visual analysis → multimodal-looker

  **When NOT to delegate**:
  - Simple file edits
  - Direct user questions requiring immediate response
  - Single tool usage (Read, Write, Edit, Bash)

  ## Magic Keywords

  - **ultrawork** - Maximum parallelization mode
  - **search/find** - Triggers explore agent
  - **analyze/investigate** - Triggers oracle agent

  ## Continuation Enforcement

  Always complete tasks fully before stopping. Use Task tool to delegate subtasks when needed.
''
