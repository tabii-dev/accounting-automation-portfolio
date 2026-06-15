# Bank Reconciliation Engine — Xero

**Built for SMB founders staring at a bank feed full of unreconciled lines, doing the software's thinking for it.**

Status: Shipped. Tested end-to-end against the Xero demo company Clancy. Real matching, real categorisation, real audit trail, real Slack proposals. A 27-line statement processed in under 40 seconds. [Skip to the evidence](#what-actually-runs).

---

## The problem this solves

Your bank feed lands in Xero with dozens of lines a week. You open the Reconcile tab and start clicking. Some lines are easy: Xero shows a green suggestion because the invoice already exists, you click OK. Most lines are not. The supplier payment with no bill behind it, the deposit that arrived before you raised the invoice, the parking charge that needs a category. On those, Xero shows you a blank Create form and waits. You become the matching engine.

This is the part of reconciliation that actually takes time. Xero's auto-suggest only fires when a matching record already exists in the ledger, which is the easy minority. The rest is on you: remember who the payee is, hunt down the invoice, decide which account the spend belongs to, line after line, at the end of a long month when mistakes are easiest to make.

Bigger companies throw Dext, Ramp, or a full-time bookkeeper at this. Those work. They also cost per seat or per document and assume you have someone whose job is reconciliation. If you're an SMB founder doing the books between actual work, you don't need an enterprise finance stack. You need the thinking done before you sit down, in a queue you can act on in seconds, with a record of why the system proposed what it did.

That's what this builds. Not a replacement for the reconcile click, which Xero reserves for a human anyway, but a removal of the slow decision that comes before it.

---

## What it does, in one sentence

When a bank statement arrives, the system reads every line, proposes a match against your Xero invoices and bills or a category against your chart of accounts, posts each proposal to Slack in plain language, and routes anything it isn't sure about to a human review queue.

## What it does not do

- It does not reconcile lines in Xero. Xero's API forbids reconciling bank statement lines, so the final click stays with the human, where it belongs.
- It does not write anything to Xero at all. Every Xero call is a read: invoices, bills, contacts. No Payments, no journals, no bank transactions created.
- It does not pull the bank feed from Xero. Xero does not expose unreconciled statement lines through its API, so the statement comes in as a CSV, the same export a bookkeeper already downloads.
- It does not auto-post categorisations to the ledger. It proposes; the human confirms.
- It does not guess silently. Anything below confidence threshold goes to review with its context attached, not coded on a hunch.

The discipline is deliberate. Reconciliation automation that quietly posts the wrong account is worse than no automation, because you find it weeks later in a profit and loss that doesn't make sense.

---

## How it works

One workflow on a single canvas, with two trigger paths feeding one shared evaluation engine, plus a shared error notifier. About 33 nodes.

### The ingest path

Triggers when a bank statement CSV lands in a Google Drive folder. For each line, the workflow:

1. Normalises the raw CSV into canonical fields: date, amount in minor units, direction (money in or money out), reference, description, counterparty.
2. Computes a deterministic hash of each line and stores it once, so re-importing the same file never creates duplicates.
3. Hands every unresolved line to the shared evaluation engine.
4. After the run, moves the processed file to a done folder so the next trigger doesn't re-ingest it.

### The shared evaluation engine

For each line, the engine runs matching first, then categorisation if no match is found:

1. **Match against Xero.** Pulls open invoices (for money in) or bills (for money out) and tests each candidate against three hard gates: amount within tolerance, date within the invoice's lifecycle, and direction agreement. Survivors are scored on reference similarity (weighted 0.60) and contact match (weighted 0.40). A score at or above 0.85 becomes a proposed match.
2. **Categorise by rules.** If no document matches, a configurable rules table maps vendor and description patterns to account codes. A hit is deterministic, full confidence, no AI call.
3. **Categorise by AI.** If no rule fits, the engine sends the transaction and your actual chart of accounts to an AI model and asks for the single best account code with a confidence score.
4. **Route to review.** If the AI's confidence is below threshold, the line goes to a human review queue with its partial reasoning attached.
5. **Notify and log.** Every outcome posts to Slack in plain language and writes an immutable row to the audit log.

### The webhook path

Triggered by Xero events on invoices, contacts, and credit notes. When a new invoice arrives, the engine re-evaluates everything sitting in the review queue. This is the real-time win: the most common reason a bank line can't be matched is that the invoice hadn't been raised yet. When it appears, the engine retries the match automatically instead of waiting for the next file.

### The learning loop

When a human resolves a reviewed line, the decision can be written back to the rules table. The next time that vendor appears, a rule catches it at full confidence and the AI is never called. The system gets more accurate and cheaper to run the longer it operates, without anyone training a machine learning model.

---

## Compliance controls baked in

This is where ACA training shows up. The same posture as the rest of the portfolio:

1. **Idempotent ingestion.** Each line gets a deterministic hash built from its account, date, amount, direction, reference, and a position marker that keeps two genuinely identical same-day transactions distinct. Re-importing the same CSV, or two overlapping runs, produces zero duplicate rows. The hash is computed inside Postgres, so the identifier is stable across runs.
2. **Append-only audit log.** Every action (a proposed match, a categorisation, a route to review, a completed run) writes an immutable row. A Postgres trigger blocks updates to identity fields and blocks DELETE entirely.
3. **One live proposal per line.** A new proposal supersedes the old one in a single atomic database operation, enforced by a partial unique index, so a line is never left in a half-updated state if something fails mid-step.
4. **Read-only Xero access.** The engine reads invoices, bills, and contacts and writes nothing back. There is no path by which it can alter the ledger.
5. **Config-driven thresholds.** Tolerances, the date window, scoring weights, and confidence thresholds all live in a configuration table, tunable per client without touching the workflow.
6. **Direction gate.** Money in can only match a sales invoice, money out can only match a bill. A single rule that removes a whole class of false matches.
7. **Lifecycle date matching.** Rather than a symmetric window around the due date, the valid payment window runs from the invoice issue date to the due date plus grace, which is how real payment timing works.
8. **Retry configuration.** Every external call (Xero, the AI model, Supabase, Slack) retries on transient failure.
9. **Human in the loop by design.** The engine proposes. It never reconciles. The final action on the books is always a human's.
10. **Structured webhook verification.** The receive path confirms the Xero signature header is well-formed and the payload is a genuine Xero envelope before processing. Full cryptographic verification over the raw body is the documented production step.
11. **Workflow-run identifier.** Every audit row carries the run that wrote it, so any action traces back to its exact execution.

---

## What actually runs

Run end-to-end against Clancy, the Xero demo company. Screenshots below are live evidence, not staged.

### A real run

A 27-line statement covering two weeks of activity, processed in 38.86 seconds:

| Outcome | Lines | What it means |
|---|---|---|
| Matched to an invoice | 1 | A clean one-to-one match against an open invoice, proposed automatically |
| Categorised to an account | 15 | No document existed, so the engine assigned a GL account via rules or AI |
| Routed to human review | 11 | Genuinely ambiguous, surfaced with context instead of guessed |

Read those numbers honestly. Only three of the 27 lines had any document in Xero to match against, because most of the statement is small operating spend that never gets an invoice or bill: parking, a supermarket run, bank fees, a bakery. Those aren't matching failures, they're categorisation work, and the engine handled fifteen without a human. The eleven in review are there for real reasons, listed under deferrals below.

### The starting point

![Bank statement lines imported into Xero, all unreconciled](./screenshots/03-xero-bank-statements.png)

*27 imported statement lines, every one unreconciled. This is what the engine reads.*

### Workflow architecture

![The full workflow canvas](./screenshots/01-canvas.png)

*Four zones on one canvas. Top left, the Google Drive ingest path. Bottom left, the webhook path. Right, the shared evaluation engine: V1 invoice and bill matching, then the V2 categorisation cascade of rules, then AI, then human review.*

### Proposals in plain language

![Slack proposals with counterparty, amount, and match](./screenshots/02-slack-proposals-clean.png)

*Each proposal speaks the bookkeeper's language. Ridgeway University, plus 6,187.50, matched to INV-0025. Open Xero, find that line, reconcile. The early version of this posted raw database hashes, which no human can act on; the fix was to carry the line's real fields through to the message.*

### The proposal confirmed in Xero

![Xero Reconcile tab: a matched invoice on one line, a blank Create form on the next](./screenshots/04-xero-reconcile.png)

*The whole argument for the project, in one screenshot. The top line has a green suggestion because the invoice existed. The line below it, SMART Agency, has nothing but a blank Create form, because no record exists for Xero to suggest. The engine proposed an account for that line. Xero did not.*

### Live audit log

![Audit log rows from real workflow runs](./screenshots/05-audit-log.png)

*Every decision is traceable. Each row records what the engine did, to which line, with what confidence, and who or what decided.*

---

## What's deferred to v2

Honest about this list, because vendors who promise everything are the ones SMB buyers learn to distrust. All three of the matching cases came up in real testing.

- **Many-to-one payments.** One bank line of 4,500 that settles two separate bills of 2,000 and 2,500. The engine checks candidates one at a time, so it correctly declines to match either alone. The fix is a subset-sum check across a contact's open bills, a known and scoped piece of work.
- **Partial payments.** A customer pays 100 against a 250 invoice and signals it in the reference. The strict amount gate correctly rejects it today. Handling it needs its own proposal type, because the downstream Xero action differs from a full settlement.
- **Statement line pagination.** The Xero candidate fetch reads the first page of open documents. For the demo's handful of invoices this is complete; for a client with hundreds, pagination is required before production.
- **Cryptographic webhook verification.** v1 verifies the webhook structurally. v2 verifies the full HMAC-SHA256 signature over the raw request body, once raw body access is available at the hosting tier.
- **Multi-currency.** USD only in v1. Multi-currency adds FX handling that earns its own scope.
- **Reporting dashboard.** v1 reporting is direct SQL against the audit log. A dashboard with match rate, categorisation accuracy, and review-queue trend is worth building once there's enough audit data to make trends meaningful.

---

## The stack

Xero through its API, read-only, for invoices, bills, and contacts. n8n self-hosted or Cloud as the workflow engine. Supabase Postgres for the statement lines, proposals, rules, configuration, chart of accounts, and audit log. Google Drive as the bank statement inbox. An AI model for the categorisation fallback, prompted with structured output against the real chart of accounts. Slack for proposals and review alerts. Reuses the error notifier from the rest of the portfolio, one shared notifier because that's how a real ops team works.

If you're on QuickBooks Online instead of Xero, the same architecture transfers; the API surface differs but the workflow patterns and compliance controls don't change. Same applies to Zoho Books, FreeAgent, or any accounting system with a reasonable REST API.

---

## What this would cost to run for you

The honest answer depends on your transaction volume, but here are the variables:

- **n8n hosting.** Self-hosted on a small VPS is $5-$15/month. n8n Cloud is $20/month for the starter plan.
- **Supabase.** Free tier covers an SMB audit log comfortably. Pro tier ($25/month) if you want backups and longer retention.
- **AI categorisation.** Pennies per statement at SMB volume, and it drops over time as the rules table absorbs the recurring vendors and the AI gets called less.
- **The build itself.** Fixed-price pilot for a single customer engagement, typically two-to-six weeks depending on your chart of accounts and the shape of your bank feed.

Total ongoing infrastructure: $25-$60/month, depending on volume. Compare against the hours a reconciliation eats every month and the math is straightforward.

---

## How I worked on this

Worked the same way I'll work on yours:

1. **Validated the platform constraint on day one.** Before building the matching engine, I confirmed against Xero's own developer guidance that the API does not expose unreconciled statement lines and does not permit reconciling them. That turned the project from "auto-reconcile" into "auto-propose, human confirms" on day one rather than day five. Hitting the wall early is cheaper than hitting it late.
2. **Discovered, not assumed.** Read the real Xero invoice and bill response shapes, and seeded the categorisation engine against Clancy's actual chart of accounts, before writing the logic that depends on them.
3. **Tested node by node against real demo data.** Pinned real Xero responses and real bank lines, ran each stage in isolation, and fixed the matching gates against a genuine early-payment case (a payment that arrived 13 days before the due date and was wrongly rejected until the date gate was reworked to respect the invoice lifecycle).
4. **Tested the compliance controls deliberately.** Confirmed the append-only trigger by attempting a delete and watching the database reject it. Confirmed idempotency by re-importing the same statement and watching it produce zero new rows.
5. **One commit per discrete change**, so the previous green state was always one checkout away.

---

## Get in touch

If you're an SMB founder, a fractional CFO, or a bookkeeper running reconciliation for SMB clients, and the workflow above looks like it would save you the slow part of every month-end, the fastest way to know if I'm the right person to build this for you is a 30-minute scoping call.

I'll map your reconciliation process end to end on the call, tell you whether automation is the right answer, and quote a fixed price if it is. If it isn't, I'll say so.

- **Upwork:** [tabitha-eoke on Upwork](https://www.upwork.com/freelancers/~01954f73840469cae5)
- **LinkedIn:** [linkedin.com/in/tabitha-oke-n8n](https://www.linkedin.com/in/tabitha-oke-n8n)
- **Email:** tabithaeoke@gmail.com

I respond within one business day.

---

*Built by Tabitha Oke, ACA. Reference build against a Xero demo company, clearly labelled as portfolio work. Workflows are MIT-licensed as portfolio pieces. Production deployment in a client engagement requires a direct engagement.*
