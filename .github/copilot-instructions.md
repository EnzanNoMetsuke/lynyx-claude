When generating commit messages, always follow the Conventional Commits specification.
Format: <type>(<scope>): <description>

Types to use:
- feat: A new feature
- fix: A bug fix
- docs: Documentation changes
- style: Changes that do not affect the meaning of the code, e.g. formatting
- refactor: A code change that neither fixes a bug nor adds a feature
- perf: A code change that improves performance
- ci: Changes to CI configuration files and scripts (example scopes: GitHub, Travis, Circle, BrowserStack, SauceLabs)
- test: Adding missing tests or correcting existing tests
- chore: Changes to the build process or auxiliary tools/libraries
- revert: Revert a previous change

Note that scope is optional, but preferred to specify if relevant as long as it can be stated tersely.

Use all lowercase, except for proper nouns & names.

While the Conventional Commits spec itself does not specify verb voice and tense for the description, it's common &
preferable to use imperative, present tense describing what the commit, if applied, does, rather than past tense
describing what was done.
