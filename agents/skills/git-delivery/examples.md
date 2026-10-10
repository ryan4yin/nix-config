# Git delivery examples

These are hypothetical inputs and outputs. Apply the target repository's current conventions and
verified evidence; the formats and metadata below are conditional on each example's stated policy.

## Self-evident fix

A repository uses Conventional Commits. The staged diff corrects a misspelled command flag; no
special rationale or metadata is required.

```text
fix: correct the service timeout flag
```

The subject describes the committed change. A body would add no necessary context. Do not add an
account of finding the typo or claim a test that was not run.

## Package update with required metadata

A package repository requires an attribute prefix, old/new versions, a release-note reference, and
an automation trailer for substantially generated contributions. The user has reviewed the
contribution, the release URL is verified, and the actual tool/model are known.

```text
widget: 1.2.0 -> 1.2.1

https://example.org/widget/releases/1.2.1

Assisted-by: <actual tool> (<actual model/version>)
```

Omit explanatory prose when the update needs none, but keep the required link and trailer. Replace
placeholders only with established metadata. Another repository might require a ticket prefix or
sign-off instead; do not add this trailer universally or invent an author's identity.

## Small diff with important runtime context

The final diff replaces a driver's relative compiler lookup with an explicit packaged path. The
user's goal is hardware execution without library-path overrides. Tracing establishes that the
lookup is in the driver, correcting an earlier hypothesis about the application plugin. The final
build runs a small model without overrides. Packaging the compiler adds approximately 150 MiB to the
driver's runtime dependency closure, and compiler updates cause driver rebuilds.

A suitable message in a repository using component prefixes:

```text
driver: resolve the compiler from its packaged path

The driver discovers its compiler at runtime, so normal linker-path
fixups cannot repair the relative lookup. Use the packaged path to
support hardware execution without library-path overrides. This adds
approximately 150 MiB to the runtime closure and couples driver
rebuilds to compiler updates.
```

The diff supplies the path change. The traced behavior explains why it is needed; measured closure
impact explains its cost. Keep that durable context even though the patch is small. Verify the
linker-path limitation before claiming it; if it remains a hypothesis, label it and investigate or
omit the causal claim. Add repository-required metadata separately.

## Evidence from different revisions

Build A placed the compiler beside the driver and ran a full encoder in 60 ms. Build B changes the
lookup/layout and passes a small hardware smoke test, but the encoder has not been rerun. Full
recognition remains blocked by a separate dependency failure.

Appropriate PR verification text:

```text
The final build passes a small hardware inference test without
library-path overrides. The encoder's 60 ms result is from the earlier
layout and has not been revalidated with this build. Full recognition
remains unverified because a separate dependency fails to build.
```

Mention the old measurement only if it helps assess the change, and label it as historical. Do not
claim final-build performance or end-to-end recognition. A template checkbox for those workflows
stays unchecked. Platform, configuration, and deployment differences require the same care.

## Multi-commit PR after its scope changes

A PR originally adds a shared configuration, a consumer, and migration code. Review establishes that
the platform's existing shared configuration suffices; the final commits update the consumer and add
tests, dropping the migration. The PR targets a release branch although the default branch is the
development branch.

Review the entire branch against the actual release base. The final description could be:

```text
The consumer ignored the platform's shared configuration and used its
local default. Read the existing shared value so consumers use the
configured setting consistently.

The change updates the consumer and adds coverage for configured and
missing values. It requires no migration. The focused consumer tests
passed; the complete integration suite was not run.
```

Retain "requires no migration" when users or reviewers need that compatibility fact. Remove the
withdrawn migration feature and its stale verification claims. Do not title the PR "address review
feedback" or describe every intermediate implementation. Each commit message explains its own
logical change; the PR explains their combined behavior.

## Technical reply with a necessary exception

A reviewer asks why a custom install phase bypasses the project's usual build hook. Inspection shows
that configuration/build fit the hook, while its install target includes every component. Only one
component belongs in this output. Generated install rules and inspected output files confirm that
component-specific installation selects it.

```text
Configure and build use the project hook. Install uses the
component-specific command because the hook's install target includes
all components. The generated install rules and inspected output
confirm that only the required component is installed.
```

If those checks have not happened, replace the last sentence with the outstanding verification.
Reply in that thread when authorized. Do not turn a partial reviewer approval into approval of the
whole PR or repeat the investigation in the package comment. A local comment can preserve the
constraint: "The default install target includes all components; install only this component."

## Private work context in a public contribution

A bug was found in an internal customer deployment with private host names, endpoints, ticket IDs,
and logs. Its relevant technical trigger is a reconnect during a credential refresh.

```text
fix: retain refreshed credentials after reconnect

A reconnect could restore cached state after credentials were
refreshed, causing subsequent requests to fail authentication. Keep
the refreshed state when rebuilding the connection.
```

Retain the verified trigger and failure mechanism. Keep private identifiers, credential values,
personal paths, and raw internal logs out of public text. Use a closing issue reference only when it
is a verified issue in the intended public repository. Do not fetch secret-bearing payloads to
produce a more detailed explanation.
