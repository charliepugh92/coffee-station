Run all quality and security checks for both the Rails API and the Vue frontend. Fix every finding — do not add ignores or workarounds unless a patched version genuinely does not exist yet.

Run this single command and report its output:

```
/Users/charliepugh/Code/coffee-station/bin/check
```

The script runs all 8 checks in parallel (RuboCop, RSpec, Brakeman, bundle-audit, TypeScript, ESLint, Vitest, npm audit) and prints a PASS/FAIL summary. If any check fails, the full output for that check is printed. Diagnose and fix every failure before reporting done.
