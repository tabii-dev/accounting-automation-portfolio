# QuickBooks Receipt & Expense Matcher

**Built for SMB founders whose card spend hits the books as a pile of unlabelled money out, with no receipt attached to prove any of it.**

Status: Shipped. Tested end to end against a live QuickBooks Online sandbox. Six execution paths verified, both intake channels working, real attachments on real transactions, real Slack review notifications, and a full append-only audit trail. [Skip to the evidence](#what-actually-runs).

---

## The problem this solves

Your team spends on the company card all week. A tank of fuel, a run to the hardware store, lunch with a client, a load of plants for a job. Each swipe lands in QuickBooks through the card feed as a line that says nothing more than the amount and a mangled merchant code, sitting in Uncategorized Expense. The receipts, the actual proof of what the money bought, live in a glovebox, a coat pocket, or a forwarded email nobody opened.

Come month end, or worse come audit or tax time, someone has to reunite the two. Open each uncategorised charge, work out what it was, pick the right account, hunt for the receipt, and staple it on. It is slow, it is easy to get wrong, and it is exactly the work that gets skipped until a deadline forces it. Unsubstantiated expenses are not a small problem either: a deduction without a receipt behind it is a deduction that does not survive scrutiny.

Bigger companies throw Expensify, Ramp, or Dext at this. Good tools. They also charge per user, per month, and they want to be the system of record, which means another subscription and another place your data lives. If you are an SMB founder who already pays for QuickBooks, you do not need a second finance platform. You need the receipts matched to the charges already in your books, coded correctly, and filed, without you opening a single transaction by hand.

That is what this builds.

---

## What it does, in one sentence

A receipt arrives by photo to a Telegram bot or by email to a dedicated inbox, the system reads it, finds the already-posted card charge it belongs to, attaches the receipt to that charge as documentation, and recodes it from Uncategorized Expense to the right account, sending anything it is not sure about to a human on Slack.

## What it does not do

- It does not approve anything. A receipt is money already spent, so there is nothing to approve. That is a different project (accounts payable), and it is deliberately kept separate.
- It does not convert foreign currency. A receipt in a currency other than USD is captured, flagged, and sent to review, not silently converted at a rate nobody checked.
- It does not invent categories. Where a receipt does not match a known rule, the AI suggests an account only from your actual chart of accounts, and a guard blocks anything that is not a real account id from ever reaching the ledger.
- It does not persist card numbers. Any visible card digits on a receipt are masked before anything is written, and raw receipt images are never stored in the audit tables.
- It does not auto-post what it is unsure about. Low confidence extractions, tip-band amount matches, ambiguous categories, and foreign currency all go to a human. The system stops automating exactly where automating stops being responsible.

The distinctive discipline here is the matching. Anyone can OCR a receipt and post an expense. The hard and useful part, the part that actually clears a bookkeeper's month-end pile, is tying each receipt to the specific charge already sitting in QuickBooks and recoding that charge in place.

---

## How it works

One workflow, two intake channels feeding a single shared pipeline, plus a shared error notifier. It is the largest workflow in the portfolio, because both intakes and the matching core live on one canvas, which keeps the whole substantiation loop in one testable place.

![Workflow overview](./screenshots/04-workflow-overview.png)

_The full engine. Two triggers on the left (Telegram and Gmail) converge into one pipeline: extract, validate, dedupe, match, categorise, then either attach and recode, post standalone, or route to review._

### 1. Intake, two channels

**Telegram.** A photo of a receipt sent to a bot. One photo, one receipt.

![Telegram intake](./screenshots/03-intake-telegram-photo.png)

**Email.** Receipts forwarded to a dedicated inbox, read on a polling trigger. One email can carry several attachments, and a PDF can run to several pages, so each attachment and each page becomes its own receipt candidate.

![Email intake](./screenshots/02-intake-email-receipts.png)

Both channels normalise to one common shape before anything downstream runs, so the rest of the pipeline never has to care where a receipt came from.

### 2. Extraction

Photos and image attachments go to an OpenAI vision model. PDFs are read through their text layer. Either way the output is structured: vendor, date, total, tax, line items, currency, payment method if visible, each field carrying a confidence signal. Receipts are far messier inputs than invoices, faded thermal paper, angled photos, smudges, so the confidence scoring is not optional; it is the thing that keeps a bad read from posting.

### 3. Validation

Line items plus tax must reconcile to the total within two cents, the date must be sane, and the extraction confidence must clear a threshold. Anything that fails goes to review rather than forward.

### 4. The matching core (the differentiator)

The system queries QuickBooks for posted card or cash purchases still sitting in a holding account (Uncategorized Expense), then scores each receipt against them:

- **Date is a hard gate.** The charge must fall from one day before the receipt date to five days after, because card charges post a day or two behind the purchase.
- **Amount is a hard gate, and asymmetric.** The posted charge must be at or above the receipt total minus two cents, and at or below the receipt total times 1.25. The upper band absorbs a tip, which is the receipt-specific wrinkle that a naive exact-amount match would miss on every restaurant charge.
- **Vendor is a weighted score, not a gate.** Card descriptors are mangled ("SQ COFFEE 4471" for a place your receipt calls "Joe's Coffee"), so vendor similarity informs the score but never blocks a match on its own.

Both hard gates must pass for a charge to qualify. Then a weighted score across exact amount, vendor similarity, and date proximity decides the outcome. An exact amount with a strong vendor and a tight date auto-attaches. A tip-band amount, or a fuzzy vendor, or several close candidates, goes to a human.

### 5. On a confident match

The receipt is attached to that exact charge as documentation, and the charge is recoded from Uncategorized Expense to the correct account. The transaction does not move anywhere; it stays where it is in your books and simply becomes correct and documented.

### 6. On no match

Receipts often arrive before the card feed posts. When nothing matches, the system posts a fresh standalone expense from the receipt, coded and dated correctly, with the vendor resolved against your QuickBooks vendor list, the receipt attached, and a memo flagging it as receipt-originated and pending the eventual bank match. Nothing is lost just because the feed was slow.

### 7. Categorisation

A rules engine runs first: vendor patterns mapped to real account ids in a table you control. Where no rule fits, the AI suggests an account, but only from your actual chart of accounts, and a numeric-id guard blocks any answer that is not a real account. Below a confidence threshold, it goes to review.

### 8. Review queue

Everything uncertain lands in a Supabase table with a Slack notification: low confidence extractions, validation failures, unmatched items, ambiguous matches, ambiguous categories, and foreign currency.

![Review queue in Slack](./screenshots/06-review-queue-slack.png)

_Two receipts routed to a human: a restaurant charge whose amount sat in the tip band, and a London cafe receipt in GBP flagged as foreign currency. Both correctly held back from auto-posting._

---

## Compliance controls baked in

This is where the ACA training shows up. The same posture as the rest of the portfolio, adapted to receipts:

1. **Idempotency on the post.** Dedupe and idempotency run on a composite key of normalised vendor, receipt date, and total in minor units, with a partial unique index that permits only one posted receipt per key. The same receipt submitted twice, once forwarded and once photographed, is caught and skipped.
2. **Append-only audit log.** Every extraction, match, categorisation, and post writes a row to an event log. A Postgres trigger blocks UPDATE and DELETE on it entirely.
3. **Identity-immutable records.** The receipts and review tables block DELETE and block edits to their identity fields, while still allowing the status enrichment the pipeline needs as a receipt flows through.
4. **PII handling.** Visible card digits are masked before any write, a raw card number is never persisted anywhere, and raw receipt image bytes are never stored in the relational tables, only a reference.
5. **Human in the loop.** Anything below the confidence threshold, plus every ambiguous match, ambiguous category, and foreign-currency receipt, goes to a person.
6. **Structured errors, no silent failures.** A receipt that cannot complete ends in a FAILED state with the failing check recorded, not a swallowed error.
7. **Retries on every external call.** QuickBooks, OpenAI, Supabase, Slack, Telegram, and Gmail all retry with backoff.
8. **Fresh-token writes.** Every QuickBooks update refetches the transaction immediately before writing, so a stale sync token can never clobber a concurrent change.
9. **Constrained AI.** The categorisation model chooses only from your real chart of accounts and returns an account id, and a numeric guard rejects anything else, so the AI can never post an invented account.

---

## What actually runs

Six execution paths tested end to end against Craig's Design and Landscaping, the QuickBooks Online sandbox company. All six passed. The screenshots are live evidence, not staged.

### Before: the pile this clears

![Before, uncategorized expenses](./screenshots/01-before-uncategorized-expenses.png)

_Four card charges sitting in Uncategorized Expense with no receipt attached. This is the raw material: money out, unlabelled, undocumented. Exactly the month-end pile._

### After: matched, categorised, attached

![After, matched and categorized and attached](./screenshots/05-after-matched-categorized-attached.png)

_The same charges after the engine ran. Hicks Hardware recoded to Job Expenses, Chin's Gas and Oil to Automobile Fuel, Squeaky Kleen Car Wash to Automobile, each with the paperclip showing the receipt now attached. Bob's Burger Joint correctly left uncategorised because it went to review._

### The standalone path: a receipt with no matching charge

![Standalone intake in Telegram](./screenshots/07-standalone-intake-tanias.png)

_A Tania's Nursery receipt sent in, with no matching charge seeded in QuickBooks, the common case where the receipt beats the card feed._

![Standalone expense posted and attached](./screenshots/08-standalone-posted-attached.png)

_The engine posted a fresh expense, dated to the receipt not to today, payee resolved to the real vendor despite the caps and the apostrophe, coded to Job Expenses, receipt attached. The no-match branch captures spend the feed has not delivered yet._

The six paths, all verified: matched and recoded with the receipt attached; a tip-band amount routed to review; a foreign-currency receipt routed to review; AI categorisation constrained to the real chart with a numeric guard; a standalone post with vendor lookup and attachment for a receipt with no match; and a duplicate receipt skipped by the composite dedupe.

---

## What is deferred to v2

Honest about the boundaries, because a build that claims to do everything is the one buyers learn to distrust:

- **Scanned image-only PDFs.** The PDF path reads the text layer, so a digitally generated PDF receipt extracts cleanly, but a scanned or photographed PDF with no text layer has nothing to read and is routed to review. Rasterizing those pages to images for the vision model is v2 work.
- **Multi-currency conversion.** Foreign currency is captured and flagged in v1, not converted. Conversion adds FX rate handling that earns its own scope.
- **Fuzzy vendor auto-match.** Vendor lookup normalises for case and punctuation, so caps and apostrophes are handled, but a receipt whose printed name differs substantially from the ledger name is matched loosely rather than perfectly. Stronger fuzzy matching is v2.
- **Learning from corrections.** The rules table plus human review is the substitute for now. Training on past categorisation decisions is deferred.
- **Mileage, per diem, and travel policy.** Out of scope. Those are their own workflow.
- **Multi-entity.** One QuickBooks company in v1.

---

## The stack

QuickBooks Online (sandbox and production), n8n self-hosted, Supabase Postgres for the audit log, review queue, and rules table, OpenAI for vision extraction and constrained categorisation, a Telegram bot and a Gmail inbox for the two intake channels, and Slack for the review notifications. Attachments and recodes go through the QuickBooks Attachable upload and Purchase update endpoints. Roughly fifty nodes on a single canvas plus a shared error notifier.

If you are on Xero rather than QuickBooks Online, the architecture transfers. The API surface differs but the matching logic, the compliance controls, and the human-review boundary do not change.

---

## What this would cost to run for you

The honest answer depends on receipt volume, but the variables are small:

- **n8n hosting.** Self-hosted on a small VPS is 5 to 15 dollars a month.
- **Supabase.** The free tier covers an SMB audit log comfortably; the Pro tier at 25 dollars a month adds backups and longer retention.
- **OpenAI.** Vision extraction and categorisation run a few cents per receipt. A business processing a few hundred receipts a month spends single-digit dollars.
- **Telegram and Gmail.** Free at SMB volume.
- **The build itself.** A fixed-price pilot, scoped to your chart of accounts and the shape of your card spend.

Total ongoing infrastructure lands around 30 to 50 dollars a month. Compare that against the hours a bookkeeper spends reuniting receipts with charges every month and the math is straightforward.

---

## How I worked on this

Built against a live QuickBooks sandbox, tested path by path, fixed what broke, repeated. The same way I would work on yours. A few of the things that only surface when you actually run it against real QuickBooks, and that a build which was never tested end to end would miss:

1. **The QuickBooks attachment endpoint is not a normal JSON post.** It is a multipart upload with a separate file part and a JSON metadata part, and each part needs its own content type. Discovered by hitting the exact error QuickBooks throws when you send it plain text, then building the metadata as a real JSON part.
2. **A Purchase update needs PaymentType and the paid-from account even on a sparse edit.** Recoding a single line still has to echo those fields back, or QuickBooks rejects the whole update.
3. **Sync tokens go stale fast.** Attaching to a transaction and then recoding it means the token you captured a moment ago is already old, so every write refetches the transaction first.
4. **The AI will invent account names.** Asked to categorise freely, the model returned a plausible account that does not exist in the chart, which then failed at the ledger. The fix was to constrain it to the real account list and add a numeric-id guard that refuses anything else.
5. **QuickBooks vendor queries are exact and case sensitive.** A receipt reading "TANIA'S NURSERY" will not match the ledger's "Tania's Nursery" on an exact query, and the apostrophe breaks the query outright. The fix was to pull the vendor list and match on a normalised name, the same normalisation the dedupe uses.

Every compliance control was tested deliberately, not assumed. The append-only trigger was tested by trying to update an event row and confirming the database rejected it. The dedupe was tested by sending the same receipt twice and confirming the second was skipped. The review routing was tested by sending a receipt engineered to land in the tip band and confirming it reached Slack instead of posting.

---

## Get in touch

If you are an SMB founder drowning in card receipts, a fractional CFO cleaning up unsubstantiated spend across a client portfolio, or a bookkeeper who spends month-end reuniting charges with paper, and this looks like it would give you that week back, the fastest way to find out if I am the right person to build it is a 30-minute scoping call.

I will map how receipts move through your business today, tell you whether automation is the right answer, and quote a fixed price if it is. If it is not the right fit, I will say so.

- **Upwork:** [tabitha-eoke on Upwork](https://www.upwork.com/freelancers/~01954f73840469cae5)
- **LinkedIn:** [linkedin.com/in/tabitha-oke-n8n](https://www.linkedin.com/in/tabitha-oke-n8n)
- **Email:** tabithaeoke@gmail.com

I respond within one business day.

---

_Built by Tabitha Oke, ACA. Workflows are MIT-licensed as portfolio pieces. Production deployment in a client engagement requires a direct engagement so the configuration, security, and compliance posture can be tailored to your specifics._
