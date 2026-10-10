# Git delivery examples

Illustrative messages that follow [SKILL.md](SKILL.md). Repository conventions still decide prefixes
and trailers. Keep the important consequence in the commit; use the PR for context and review
details.

## A self-explaining change

```text
feat(cli): add a --json flag to the status command
```

The flag explains its effect. Which script asked for machine-readable output belongs in the PR, not
a commit body.

## A deletion outside the diff

```text
fix(logs): delete rotated logs older than seven days

Every nightly run deletes rotated logs older than seven days, including unshipped ones.
Logs already shipped to the archive are unaffected.
```

The body names the runtime deletion and what survives. These consequences matter when someone
investigates missing logs; file lists and debugging history do not.

## A stored format changes meaning

```text
fix(config): store the sync interval as a duration string

Integer intervals are read as seconds once and rewritten on the next save.
Clients older than 2.4 cannot read the rewritten value.
```

The body records the compatibility effect. Upgrade order and measured impact belong in the PR when
they help review.

## Cite the commit being fixed

```text
fix(logs): keep unshipped logs during rotation

Rotation skips unshipped logs again; logs it already deleted cannot be recovered.

Refs: 9f8e7d6 (fix(logs): delete rotated logs older than seven days)
```

A hash with its subject identifies the earlier change without a lookup. Use the repository's trailer
format; required disclosure follows the body too.

## Separate PR review points

```markdown
Rotation keeps unshipped logs, so a slow archive upload no longer loses them. Review the shipping
check in `rotate.py` first.

- Logs deleted before this change cannot be recovered.
- Disk use grows while the archive is unreachable; the existing disk alert still fires at 90%.
- The rotation test now covers an unshipped log; no host has run the new rotation yet.
```

Distinct points get separate lines. Word limits bound the content; useful paragraph breaks and
bullets do not spend that budget.
