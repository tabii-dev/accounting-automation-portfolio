# Accounting & Finance Automation Portfolio

**For small business owners who are tired of being their own bookkeeper, AR clerk, and AP clerk all at once.**

You started the business to do the work you're good at. Now half your week goes to chasing late invoices, processing bills, reconciling Stripe payouts that never match your bank deposit, and trying to remember whether you already paid that vendor. The accounting software helps but it doesn't do the work. You do.

I build the systems that take that work off your plate, in your voice, on the tools you already pay for, so the chasing happens without you and your books stop being painful.

I'm Tabitha. I'm an ACA-credentialed accountant (the chartered version, not the bookkeeper version) and I build automation that respects how accounting actually works. Compliance aware by design. No platform tax. Workflows you own.

---

## Who this is for

You're in the right place if you are:

**A small business owner or founder** running QuickBooks Online or Xero, doing $500K to $5M in revenue, and the bookkeeping is eating your evenings or your weekends. Could be a service business, a contractor, a small retail shop, a restaurant, an e-commerce store. The pain is the same: too many manual steps, too easy to forget one, too expensive to hire a full-time finance person.

**A bookkeeper or fractional CFO** managing 3 to 10 SMB clients and looking for systems you can deploy across the portfolio without rebuilding from scratch each time. You want the workflow to survive after your engagement ends, not lock the client into your subscription.

**An e-commerce finance lead** where Shopify, Stripe, PayPal, and your bank deposit never agree on the same number. You know the payout breakdown exists but the manual reconciliation is killing your month-end.

You're probably not in the right place if you need a NetSuite implementation, a custom ERP build, or someone to sign off your financial statements. I build the workflows. Your accountant still signs your returns.

---

## What I build

I work on a defined set of accounting and finance workflows. Each one solves a specific problem most SMBs have, with the discipline of someone who's read the trial balance, not just connected the API.

### Accounts payable automation
Bills arrive, get coded, get approved by the right person at the right threshold, and post to QuickBooks. Five validation checks run before anything touches the ledger. Materiality-based approval routing through Slack. Immutable audit log on every transaction. **[Shipped → Read the case study](./quickbooks-ap-invoice-automation/README.md)**

### Accounts receivable automation
Overdue invoices get chased automatically, in your voice, with reminders that tone up appropriately as time passes. Trusted long-term customers get gentler handling. The moment payment lands, the chasing stops. At 60+ days, the system flags you on Slack because some conversations need a human. **[Shipped → Read the case study](./quickbooks-ar-collections-automation/README.md)**

### Bank and payment gateway reconciliation
Stripe and Shopify payout reconciliation that breaks down the fees, refunds, and rolling reserves automatically. No more spending Sunday afternoons matching a $4,200 Stripe deposit to 47 orders. **Coming soon.**

### Month-end close orchestration
The checklist that runs your close, sequences the dependencies (bank rec before AR close, AR before AP cutoff, accruals before reports), and routes approvals at the right gates. **Coming soon.**

### Logic-driven journal automation
Recurring journals, prepayment unwinds, depreciation schedules, accrual reversals. Built so your bookkeeper can adjust the logic without rebuilding the workflow. **Coming soon.**

### Cash flow forecasting
A 13-week rolling forecast refreshed daily from your bank feed, AR aging, recurring invoices, and payroll commitments. Liquidity flags when things drift. **Coming soon.**

### Client document collection
For accounting firms and fractional CFOs: the system that chases your clients for the documents they owe you, escalates politely, and files everything in the right folder structure. **Coming soon.**

---

## How I work

**Compliance aware, not compliance certified.** I'm an ACA. That means I trained under audit standards and I design audit trails into every workflow. It does not mean I'm your auditor. Your accountant still handles the actual accounting.

**Configure manually first, automate after.** The first month of any recurring entry is your team running it manually with the workflow watching. Once one clean cycle is on the books, automation takes over. This is how I make sure the system matches your reality, not my assumptions.

**Discovered, not assumed.** I read your chart of accounts, your customer list, and your existing workflows before I write a single node. Nothing is hardcoded that should be configurable. Most automation builders skip this step and ship something that breaks the moment you add a new account.

**Documented handover.** Every workflow ships with a one-page runbook, a control map, and a change log. If you replace me with another builder in eighteen months, they should be able to pick up where I left off in a day.

**Human in the loop where it matters.** Routine entries auto-post. Material amounts always require a human. The system stops automating where automation stops being responsible.

---

## A note on AI

Most accounting automation right now is being sold with AI in the title and brittle pattern matching underneath. The best AI model tested by DualEntry in 2025 scored 79.2% accuracy on real accounting workflows. That's not something you let near your general ledger without controls.

Everything I build has explicit validation, human-review gates where they matter, and a fail-safe path you can actually run. AI is in the workflow where it earns its place. Where it doesn't, it's not.

---

## Portfolio workflows

| Workflow | Status | What it does |
|---|---|---|
| [QuickBooks AP Invoice Automation](./quickbooks-ap-invoice-automation/README.md) | Shipped | Bills get coded, approved, and posted with five validation checks and immutable audit log |
| [QuickBooks AR Collections Automation](./quickbooks-ar-collections-automation/README.md) | Shipped | Overdue invoices get chased politely, escalated when needed, and the sequence stops the moment payment lands |
| Stripe + Shopify Revenue Reconciliation | In development | Payout decomposition with fee, refund, and FX handling |
| Month-End Close Orchestrator | Planned | Checklist-driven close with dependency sequencing and approval gates |
| Cash Flow Forecasting Engine | Planned | 13-week rolling forecast with liquidity risk flags |
| Client Document Collection Bot | Planned | Automated KYC, W-9, and engagement letter capture for accounting firms |

---

## Working together

If you've read this far and the workflows look like they'd save you a week of finance admin per month, the fastest way to know if I'm the right person to build for you is a 30-minute scoping call.

On the call: I'll map your current process end to end, tell you whether automation is the right answer, and quote a fixed price if it is. If it's not the right fit, I'll say so on the call and point you to whoever is.

**Engagements come in three shapes:**

**Fixed-price pilots.** One well-scoped workflow from kickoff to production, typical range $1,500 to $5,000 depending on the integrations and your account shape. Two to six weeks. Includes the runbook, the control map, and a 30-day support window after go-live.

**Retainers.** For SMBs running multiple workflows in production, or fractional CFOs deploying patterns across a portfolio. Monthly retainer covers maintenance, schema changes when your chart of accounts evolves, and a small allowance for new builds.

**Audit and improvement.** For teams that already have automation in place but suspect it's not as defensible as it should be. I review your current workflows, write up what works, what doesn't, and what specifically needs to change.

I don't sell hours and I don't sell seats. I sell working systems.

---

## Stack

n8n as the workflow engine, self-hosted or Cloud. Supabase or Postgres for audit logging. QuickBooks Online and Xero as primary accounting integrations. Stripe, Shopify, PayPal, GoCardless on the revenue side. Slack and email for human-in-the-loop. Claude for AI-assisted development of the workflows themselves.

If your stack is somewhere else, I can usually still help. Most accounting systems have an API and the patterns transfer.

---

## Get in touch

- **Upwork:** [tabitha-eoke on Upwork](https://www.upwork.com/freelancers/~01954f73840469cae5)
- **LinkedIn:** [linkedin.com/in/tabitha-oke-n8n](https://www.linkedin.com/in/tabitha-oke-n8n)
- **Email:** tabithaeoke@gmail.com

I respond within one business day. If you have a brief already written, send it over and I'll come to the call with questions, not a sales pitch.

---

## License

The workflows and code in this portfolio are published as portfolio pieces under the MIT License. Production deployment in a client engagement requires a direct engagement so the configuration, security, and compliance posture can be tailored to your specifics. See individual workflow folders for per-workflow license variations.
