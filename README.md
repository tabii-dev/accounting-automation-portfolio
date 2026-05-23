# Accounting & Finance Automation Portfolio

n8n workflows for SMB finance teams, fractional CFOs, accounting firms, and e-commerce finance ops. Built by an ACA-credentialed accountant who reads your trial balance, not just your tech stack.

I'm Tabitha. I trained as a chartered accountant (ICAN ACA, AAT) and I now build automation that finance teams actually trust. Compliance-aware by design. No platform tax. Workflows you own.

---

## Independent of the platforms you're already comparing

I'm not building you another Bill.com or Tipalti. Those are good products at scale. They also charge per user, per transaction, and assume you have an AP clerk and a procurement function. Most SMB finance teams don't.

The workflows in this portfolio sit on top of the tools you already pay for: QuickBooks Online, Xero, Zoho Books, Stripe, Shopify, your bank, your payroll provider and stitch them together with logic that matches how your team actually closes the books. You own the workflow. There's no per-user fee. When the engagement ends, the system stays.

---

## Who this is for

You're in the right place if you are:

**An SMB in-house finance team** (50–250 employees) running QuickBooks Online, Xero, or Zoho Books, and your controller is doing AP on Friday afternoons.

**A fractional CFO** juggling 3–10 clients, tired of rebuilding the same close pack every month, and looking for tech you can deploy across the portfolio.

**A small accounting or bookkeeping firm** with 20–100 clients losing days to manual reconciliation and document chasing.

**An e-commerce finance ops lead** where Shopify, Stripe, PayPal, and your bank deposit never agree on the same number.

You're probably not in the right place if you need an SAP migration, a NetSuite implementation, or someone to sign off your financial statements. I build the plumbing. Your audit firm signs the returns.

---

## What I build

Seven service areas. Each named below with an honest status flag; what's shipped, what's coming, and what proof I can show you.

### Accounts payable automation

Invoice intake from a shared inbox or OCR. Vendor lookup against your live chart of accounts. Materiality-based approval routing through Slack. Pre-posting validation gate that catches balance errors, COA mismatches, closed periods, and out-of-scope authorisations before they hit the ledger. Idempotent retry handling. Immutable audit log.

**Shipped.** The AP Invoice Orchestrator processes a real invoice from webhook to QuickBooks Bill in under 90 seconds, with five distinct execution paths tested end-to-end. [Read the case study →](./quickbooks-ap-invoice-automation/README.md)

### Accounts receivable automation

Dunning sequences in your voice, segmented by aging bucket, customer payment history, and invoice value tier. Payment matching with tolerance logic for short pays. Escalation rules when an account hits 60 days. Collection activity posted back to QuickBooks or Xero.

**Shipped.** Two-workflow system handling overdue invoice detection, tag-aware dunning schedules, payment detection via QBO webhook, and Slack escalation at 60+ days overdue. Tested end-to-end against a live QuickBooks Online sandbox. [Read the case study →](./quickbooks-ar-collections-automation/README.md)

### Bank and payment gateway reconciliation

Stripe and Shopify payout reconciliation that breaks down fees, refunds, rolling reserves, and FX without a spreadsheet. Multi-channel matching for SMBs selling across Amazon, eBay, TikTok Shop, and direct. Exception reporting for the unmatched.

**Coming soon.**

### Payroll close automation

Period-end accrual postings for Gusto, ADP, Xero Payroll, or Zoho Payroll. Statutory filing reminders calibrated to your jurisdiction. Pension and benefits journal automation.

**Coming soon.**

### Logic-driven journal automation

Recurring journals, prepayment unwinds, depreciation schedules, accrual reversals. Versioned, documented, and built so your team can adjust the logic without rebuilding the workflow.

**Coming soon.**

### Cash flow automation and reporting

13-week rolling forecast refreshed daily from your bank feed, AR aging, recurring invoices, and payroll commitments. Liquidity risk flags. Scenario modelling for slow-pay clients or delayed receipts.

**Coming soon.**

### Back-office task automation

Vendor onboarding with W-9, W-8, or KYC capture. Client document collection workflows. AML screening hooks. Periodic client reporting packs for accounting firms managing 20+ clients.

**Coming soon.**

---

## How I work

**Compliance-aware, not compliance-certified.** I'm an ACA. That means I trained under audit standards and I design audit trails into every workflow. It does not mean I'm your auditor. Your registered firm signs the returns.

**Configure manually first, automate after.** The first month of any recurring entry is your team running it manually with the workflow watching. Once one clean cycle is on the books, automation takes over. This is how I make sure the system matches your reality, not my assumptions.

**Discovered, not assumed.** I read your chart of accounts before I write a single node. I read your payment terms. I read your tax setup. Nothing is hardcoded that should be configurable. You'd be surprised how rarely this happens.

**Documented handover.** Every workflow ships with a one-page control map, a change log, and a runbook your team can read without me. If you replace me with another builder in 18 months, they should be able to pick up where I left off in a day.

**Human in the loop above materiality.** Routine entries auto-post. Material amounts always require a human. I'd rather slow you down on a $8,000 invoice than have a workflow auto-post something that needed someone's eyes.

---

## A note on AI

Most accounting automation right now is being sold with AI in the title and brittle pattern matching underneath. The best AI model tested by DualEntry in 2025 scored 79.2% accuracy on real accounting workflows. That's not a system you let near a general ledger without controls.

Everything I build has explicit validation, human-review gates where they matter, and a fail-safe path you can actually run. AI is in the workflow where it earns its place. Where it doesn't, it's not.

---

## Portfolio workflows

| Workflow                                                                 | Status         | What it does                                                                                                    |
| ------------------------------------------------------------------------ | -------------- | --------------------------------------------------------------------------------------------------------------- |
| [AP Invoice Orchestrator](./quickbooks-ap-invoice-automation/README.md)  | Shipped        | Invoice intake to GL posting with 5-check pre-posting gate, materiality-based approval, and immutable audit log |
| [AR Collections Agent](./quickbooks-ar-collections-automation/README.md) | Shipped        | Tag-aware dunning schedules, payment detection via webhook, 60-day escalation, append-only audit log            |
| E-commerce Revenue Reconciliation                                        | In development | Stripe and Shopify payout breakdown with fee, refund, and FX handling                                           |
| Month-End Close Orchestrator                                             | Planned        | Checklist-driven sequencing for sub-ledger rec, accruals, and controller approval                               |
| Cash Flow Forecasting Engine                                             | Planned        | 13-week rolling forecast with liquidity risk flags                                                              |
| Client Document Collection Bot                                           | Planned        | Automated KYC, W-9, and engagement letter capture for accounting firms                                          |

---

## Engagements

I work in three shapes:

**Scoping calls.** Free, 30 minutes. We map one process end to end on the call. I tell you whether automation is the right answer for it. If it isn't, I'll say so and point you to whoever is.

**Fixed-price pilots.** One well-scoped process from kickoff to production. Two-to-six week timeline depending on integrations. Includes the control map, runbook, and a 30-day support window. Pricing depends on scope and we work it out on the call.

**Retainers.** For finance teams or fractional CFOs running multiple workflows in production. Monthly retainer covers maintenance, schema changes when your COA evolves, and a small allowance for new builds.

I don't sell hours and I don't sell seats. I sell working systems.

---

## Stack

n8n as the workflow engine, self-hosted or Cloud. Supabase or Postgres for audit logging. QuickBooks Online and Xero as primary accounting integrations. Zoho Books, Sage, and FreeAgent for clients running those. Stripe, Shopify, PayPal, GoCardless on the revenue side. Slack and email for human-in-the-loop. Claude for AI-assisted development.

If your stack is somewhere else, I can usually still help. Most accounting systems have an API and the patterns transfer.

---

## Get in touch

The fastest way to know if I'm the right person to build this for you is a 30-minute call.

- **Upwork:** [tabitha-eoke on Upwork](https://www.upwork.com/freelancers/~01954f73840469cae5)
- **LinkedIn:** [linkedin.com/in/tabitha-oke-n8n](https://www.linkedin.com/in/tabitha-oke-n8n)
- **Email:** tabithaeoke@gmail.com

I respond within one business day. If you've already got a brief written, send it over and I'll come to the call with questions, not a sales pitch.

---

## License

The workflows and code in this portfolio are published as portfolio pieces under the MIT License. Production deployment in a client engagement requires a direct engagement. See individual workflow folders for any per-workflow license variations.
