# DECODE — Signal Verification Patches

> When a tool says "success" or says nothing, verify independently.

These lessons fix the **perception blindness deficit**: Agent trusts tool output
at face value without verifying the actual effect.

## Lessons

<!-- Add lessons from /harness:compound -->

_No lessons yet._

## Common DECODE Patterns

- sed with no output doesn't mean success (verify the file changed)
- Empty test output might mean tests didn't run (check exit code)
- "Build succeeded" doesn't mean the feature works (run integration test)
- Git push "success" — check remote actually received the commits
