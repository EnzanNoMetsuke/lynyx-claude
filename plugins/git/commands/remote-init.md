---
description: Create a new GitHub repository and set as remote
argument-hint: <repo_name> <private|public> [push]
---

# Git Remote Init

Create a new GitHub repository using the GitHub CLI and set it as the remote origin.

## Prerequisites Check

### 1. Check GitHub CLI Installation

Run:
```bash
gh --version 2>/dev/null
```

If command fails:
- Output error: "GitHub CLI (`gh`) is not installed."
- Provide installation instructions:
  - macOS: `brew install gh`
  - Linux: See https://github.com/cli/cli/blob/trunk/docs/install_linux.md
  - Windows: See https://github.com/cli/cli#installation
- Stop execution

### 2. Check GitHub CLI Authentication

Run:
```bash
gh auth status 2>&1
```

Check if output contains "Logged in":
- If NOT logged in:
  - Output error: "GitHub CLI is not authenticated."
  - Provide authentication instructions:
    - "Run: `gh auth login`"
    - "Follow the prompts to authenticate with GitHub"
  - Stop execution

## Parse Arguments

1. Split `$ARGUMENTS` by whitespace
2. First argument = `repo_name` (required)
3. Second argument = `visibility` (required: must be "private" or "public")
4. Third argument (if present and contains "push") = `push_flag`

### Validate Arguments

**Missing repo_name:**
- If first argument missing:
  - Use AskUserQuestion: "Enter repository name:"
  - Store as `repo_name`

**Missing or invalid visibility:**
- If second argument missing OR not "private"/"public":
  - Use AskUserQuestion:
    - Question: "Select repository visibility:"
    - Options:
      - "Private" → set `visibility = "private"`
      - "Public" → set `visibility = "public"`

**Extract push flag:**
- Check if any argument contains "push"
- Set `push_flag = true` if present, otherwise `false`

## Check for Existing Remote

Run:
```bash
git remote get-url origin 2>/dev/null
```

If command succeeds (returns a URL):
- Use AskUserQuestion:
  - Question: "Remote 'origin' already exists pointing to:\n{{current_url}}\n\nWhat would you like to do?"
  - Options:
    - "Replace with new remote" - Continue with repo creation
    - "Abort (no changes)" - Stop execution

- If "Abort" selected:
  - Output: "Operation cancelled. No changes made."
  - Stop execution

- If "Replace" selected:
  - Note: Will update remote URL after repo creation

## Build Command

Construct the `gh repo create` command:

1. Base command: `gh repo create {{repo_name}}`
2. Add visibility flag:
   - If `visibility = "private"`: add `--private`
   - If `visibility = "public"`: add `--public`
3. Add source and remote:
   - Always add: `--source=. --remote=origin`
4. Add push flag if present:
   - If `push_flag = true`: add `--push`

Final command example:
```
gh repo create my-project --private --source=. --remote=origin --push
```

## Confirm Execution

Use AskUserQuestion:
- Question: "Create GitHub repository with the following settings?"
- Show details:
  - Repository name: {{repo_name}}
  - Visibility: {{visibility}}
  - Set as origin: Yes
  - Push after creation: {{push_flag ? "Yes" : "No"}}
- Options:
  - "Yes, create repository" - Proceed
  - "No, cancel" - Abort

If "No, cancel":
- Output: "Repository creation cancelled."
- Stop execution

## Execute Command

1. Run the constructed `gh repo create` command

2. If successful:
   - Parse output to extract repository URL
   - Output success message:
     - "GitHub repository created successfully!"
     - "Repository: {{repo_url}}"
     - "Remote 'origin' set to: {{repo_url}}"
     - If pushed: "Local commits pushed to remote."

## Error Handling

**Repository name already taken:**
- Display error from GitHub
- Suggest trying a different name
- Offer to retry with new name using AskUserQuestion

**Repository creation fails:**
- Display full error message from `gh`
- Common issues:
  - Rate limit exceeded → "GitHub API rate limit reached. Try again later."
  - Network error → "Check internet connection"
  - Permission error → "Check GitHub account permissions"

**Push fails (if --push used):**
- Note that repository was created but push failed
- Display push error
- Suggest running `/git:push` manually after resolving issues

## Examples

**Create private repository:**
```
/git:remote-init my-awesome-project private
→ Create GitHub repository with the following settings?
  Repository name: my-awesome-project
  Visibility: private
  Set as origin: Yes
  Push after creation: No
→ User selects "Yes, create repository"
→ GitHub repository created successfully!
→ Repository: https://github.com/username/my-awesome-project
```

**Create public repository and push:**
```
/git:remote-init open-source-tool public push
→ Confirmation prompt
→ User selects "Yes"
→ GitHub repository created successfully!
→ Remote 'origin' set to: https://github.com/username/open-source-tool
→ Local commits pushed to remote.
```

**Handle existing remote:**
```
/git:remote-init new-repo private
→ Remote 'origin' already exists pointing to:
  https://github.com/username/old-repo

  What would you like to do?
→ User selects "Replace with new remote"
→ Create repository...
→ Remote 'origin' updated successfully
```

**Missing arguments:**
```
/git:remote-init
→ Enter repository name: my-project
→ Select repository visibility: Private
→ Proceed with creation
```

## Notes

- Requires GitHub CLI (`gh`) installed and authenticated
- Repository name must be unique in your GitHub account
- Private repositories may require a paid GitHub plan (check your account)
- The `--push` flag requires local commits to push
- Remote 'origin' is automatically configured
- Repository is created in the authenticated user's account
