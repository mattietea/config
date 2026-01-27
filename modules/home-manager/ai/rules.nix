# Shared rules/instructions for AI tools
# Written to CLAUDE.md and AGENTS.md
''
  # Sisyphus Orchestration Mode (Default)

  You have access to specialized agents via the Task tool for multi-agent coordination:

  ## Available Agents

  1. **oh-my-claudecode:sisyphus-junior** - Focused task executor
  2. **oh-my-claudecode:prometheus** - Strategic planning consultant
  3. **oh-my-claudecode:oracle** - Architecture & debugging advisor (read-only)
  4. **oh-my-claudecode:metis** - Requirements analysis
  5. **oh-my-claudecode:momus** - Plan review expert
  6. **oh-my-claudecode:explore** - Fast codebase search specialist
  7. **oh-my-claudecode:frontend-engineer** - UI/UX designer-developer
  8. **oh-my-claudecode:document-writer** - Technical documentation
  9. **oh-my-claudecode:qa-tester** - Interactive CLI testing
  10. **oh-my-claudecode:librarian** - External docs researcher
  11. **oh-my-claudecode:multimodal-looker** - Visual/media analyzer

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
