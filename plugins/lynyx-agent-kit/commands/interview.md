---
description: Interview me about a spec file to gather detailed requirements
argument-hint: [spec_file]
---

# Spec Interview

Read the spec file and conduct a thorough interview using the AskUserQuestion tool.

**Usage:** `/interview [spec_file]`
- If a spec file path is provided as an argument, use that file
- If no argument is provided, default to either `SPEC.txt` or `SPEC.md` (whichever exists) in the current project's root directory
- If a `SPEC.txt` file is discovered, use the [app_spec_template.txt](examples/app_spec_template.txt) resource as a model for the spec
  to create based off of the user's responses during the interview. Make sure to update all placeholders (e.g. `{PLACEHOLDER}`) in your
  output with the correct information or replace with "N/A" if not applicable to the project.
- If no argument is provided AND neither `SPEC.txt` nor `SPEC.md` exist in the current project's root directory, then offer to create
  a fresh `SPEC.md` if the user can provide a brief description of the project and its key requirements

## Interview Guidelines

1. **Start by reading the spec thoroughly** - understand the context, goals, and current state of the document

2. **Ask non-obvious questions** - avoid surface-level questions that the spec already answers. Focus on:
   - Edge cases and failure modes
   - Technical implementation tradeoffs
   - UI/UX considerations and user flows
   - Security and performance implications
   - Integration points and dependencies
   - Scalability concerns
   - Data models and state management
   - Error handling strategies
   - Testing approaches

3. **Be thorough and persistent** - continue the interview until you've covered all major areas. Use multi-question batches with AskUserQuestion when appropriate.

4. **Dig deeper on answers** - follow up on interesting or ambiguous responses

5. **Track coverage** - mentally note which areas you've covered and which remain

## Interview Flow

1. Read the spec file
2. Ask 2-4 initial questions about the highest-impact unknowns
3. Based on answers, ask follow-up questions
4. Continue until all major areas are covered
5. Summarize key decisions and write the updated spec to the file

## Output

After the interview is complete:
1. Summarize the key decisions and clarifications gathered
2. Write the complete, updated spec back to the original file (or a new file if specified)
3. Highlight any remaining open questions or areas needing future discussion
