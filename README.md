# Accounting & Finance Technology Portfolio

**For bookkeepers, fractional CFOs, and accounting firms whose client tools are connected on paper and out of sync in practice.**

Your client's Stripe payouts land in the bank feed as a single deposit while A2X posts the itemised breakdown. Two versions of the same money in the ledger, and someone has to sort it out before close. Gusto runs payroll and the journal posts, but the expense categories mapped at setup have drifted from the chart of accounts and you fix them by hand every pay period. Dext captures a receipt and the bank feed pulls the same card charge, and both show up in QBO as separate entries waiting to be dealt with.

The integrations exist. The sync does not. Making them sync, keeping them that way month after month, and building the reporting and automation layers that let you trust the numbers at close: that is the work I do.

I'm Tabitha. I'm a chartered accountant (ICAN ACA, AAT, Xero Advisor) who builds technology for finance and accounting teams. The combination matters here: diagnosing why a payout processor and a ledger disagree is an accounting problem before it is a technical problem. I read the chart of accounts, trace the money, find the gap, and build the fix. Sometimes that means configuring the tools you already have so they talk to each other properly. Sometimes it means custom automation to close a gap no native integration covers. Sometimes it means a reporting layer that pulls clean numbers out of a stack that is finally in agreement. The credential is not decoration. It is the reason the technical work lands right.

---

## Who this is for

**Bookkeepers and accounting firms** managing a portfolio of clients across QBO, Xero, Zoho Books, or Sage, where every client runs a slightly different stack and the integrations between tools need someone who understands both the software and the accounting to set up properly, monitor, and fix when they break. You want a builder who reads a trial balance, not someone who connects APIs and hopes the numbers work out.

**Fractional CFOs and controllers** who need the client's finance stack producing reliable numbers so you can do the advisory work you are actually hired for. Reporting packs, dashboards, forecasts, KPI tracking, all of it depends on the data underneath being clean. When it is not, your hours go to reconciling instead of advising. I make the stack trustworthy so your time goes where it should.

**Developers building accounting integrations** who need someone with domain expertise on the other side. You write the code. I make sure the accounting logic is correct: the right accounts, the right tax treatment, the right journal structure, the right audit trail. Postman collections, implementation guides, validated test sequences. The kind of documentation that means your dev team ships something an accountant will not reject.

**You are probably not in the right place** if you need someone to sign off financial statements, file your tax return, or implement a full ERP from scratch. I build the technology layer. Your accountant still handles the accounting.

---

## What I build

### Integration and stack sync

The core of what most finance teams need and struggle to get right. Your client runs QBO or Xero alongside a payment processor, a receipt capture tool, a payroll system, maybe an ecommerce platform. I configure those connections so the data flows correctly, the chart of accounts mapping makes sense, the tax and fee handling is accurate, and the reconciliation ties to the penny. Where the native integration drops the ball, I build the bridge.

This includes A2X and Link My Books setups for ecommerce revenue, Dext and Hubdoc for receipt capture and document management, Gusto and payroll journal sync, Bill.com and Ramp for AP and spend management, Stripe and Shopify and PayPal payout reconciliation, and the troubleshooting when any of these quietly stop agreeing with each other.

### Reporting and financial dashboards

Management packs, budget versus actual, KPI dashboards, cash flow reporting, and the recurring reports that eat the last two days of every month. Built in the tools your clients already use: Excel with Power Query, Google Sheets with Apps Script, Looker Studio, or Fathom. Refreshable, templated, and designed so you can run the same structure across multiple clients without rebuilding each time.

### Process automation

For the repetitive workflows that follow clear rules and happen on a schedule: accounts payable processing, accounts receivable chasing, bank statement matching, month-end close sequences, client document collection. Validation before anything posts. Human review where it matters. Error handling that tells you what went wrong instead of failing silently. Built primarily on n8n, with Make or Zapier where the client's setup calls for it.

### AI-assisted workflows

Categorisation, document extraction, matching, and the other places where a model earns its seat by handling volume while a human handles exceptions. Constrained to the client's actual chart of accounts, never inventing categories, with confidence thresholds that route uncertain items to review instead of posting them. AI where it works. Rules where it does not. Human judgement at the boundary.

---

## Shipped projects

Each project below is published in full: architecture, compliance controls, screenshots from live sandbox testing, and a detailed case study. No staged demos. Real audit logs from real workflow runs.

| Project | What it solves |
| --- | --- |
| [QuickBooks AP Invoice Automation](./quickbooks-ap-invoice-automation/README.md) | Bills captured, coded, validated five ways, routed through materiality-based approval, and posted with an immutable audit trail |
| [QuickBooks AR Collections Automation](./quickbooks-ar-collections-automation/README.md) | Overdue invoices chased automatically on a configurable schedule, escalated at 60 days, sequence cancelled the moment payment lands |
| [Xero Payment Processor Reconciliation](./xero-payment-processor-reconciliation/README.md) | Stripe and Shopify payouts decomposed into balanced Xero journals: fees, refunds, reserves, and settlements reconciled to the penny |
| [Xero Bank Reconciliation Engine](./xero-bank-reconciliation-engine/README.md) | Bank statement lines matched to invoices and bills or categorised against the chart of accounts, proposed for one-click human review |
| [QuickBooks Receipt & Expense Matcher](./quickbooks-receipt-expense-automation/README.md) | Receipts matched to posted card charges by amount, date, and vendor, attached as documentation, and recoded from Uncategorized Expense |

### Client work

| Engagement | What I did |
| --- | --- |
| Shopify-to-Xero integration (Clarendon Rocks Limited) | Diagnosed a sole-trader-to-limited-company cutover problem the connector vendor would have missed, evaluated four integration tools, recommended and configured the right one, cleaned up a partial Amaka setup, and delivered a working Shopify-to-Xero revenue pipeline with correct VAT treatment |
| QuickBooks PO receiving validation (dev team) | Found the working API method for receiving stock against Purchase Orders in QBO after the team had hit two dead ends, rebuilt the journal structure when their CPA rejected the first version, and delivered a tested Postman collection with an implementation guide |

---

## How I work

**Configure manually first, automate after.** The first cycle of any recurring process runs with a human watching. Once one clean period is on the books and the output matches reality, automation takes over. This is how I make sure the system matches your client's actual data, not my assumptions about it.

**Discovered, not assumed.** I read the chart of accounts, the customer and vendor lists, the bank feed, and the existing integrations before I build or configure anything. Nothing is hardcoded that should be configurable. Most builders skip this step and ship something that breaks the moment a new account is added or a product line changes.

**Documented handover.** Every engagement ships with a runbook, a control map, and a change log. If you replace me with another builder in eighteen months, they should be able to pick up where I left off in a day. The tools, the configuration, and the documentation stay with you.

**Human in the loop where it matters.** Routine entries and standard matches auto-process. Material amounts, uncertain categorisations, and edge cases always require a human. The system stops automating exactly where automating stops being responsible.

**Compliance aware, not compliance certified.** I trained under audit standards and I design audit trails into every system I build. That does not make me your auditor. Your accountant or firm partner still handles the actual accounting sign-off.

---

## A note on AI

Most accounting technology right now is being sold with AI in the title and fragile pattern matching underneath. The best AI model tested by DualEntry in 2025 scored 79.2% accuracy on real accounting workflows. That is not something you let near your general ledger without controls.

Everything I build has explicit validation, human-review gates where they matter, and a fail-safe path you can actually run. AI is in the workflow where it earns its place. Where it does not, it is not. No vendor hype. No black box. Testable decisions with a clear audit trail.

---

## Stack

**Accounting platforms:** QuickBooks Online, Xero, Zoho Books, Sage. If it has a reasonable API or a native integration ecosystem, the patterns transfer.

**Revenue and payments:** Stripe, Shopify, PayPal, GoCardless, Square. Payout decomposition, fee reconciliation, settlement matching.

**Receipt capture and document management:** Dext, Hubdoc. Configuration, category rules, duplicate prevention, and the sync back to the ledger.

**Ecommerce connectors:** A2X, Link My Books. COA mapping, tax treatment, COGS and inventory reconciliation.

**AP and spend management:** Bill.com, Ramp, Expensify. Invoice flow, approval routing, spend sync.

**Payroll:** Gusto, QBO Payroll, Xero Payroll. Journal posting, category mapping, period alignment.

**Reporting:** Excel (Power Query, VBA), Google Sheets (Apps Script), Looker Studio, Fathom, Power BI. Refreshable management packs, dashboards, and financial models.

**Automation and orchestration:** n8n (self-hosted or Cloud), Make, Zapier. Used when native integrations leave a gap or when a process needs a custom logic layer.

**Infrastructure:** Supabase/Postgres for audit logging and configuration state, Google Workspace and Microsoft 365 for delivery, Slack for notifications.

---

## Working together

**Fixed-price projects.** A defined scope from kickoff to production. Could be a stack integration and sync audit for a client portfolio, an automation build, a reporting pack, or a combination. Typical range $1,500 to $5,000 depending on the tools involved and the complexity. Two to six weeks. Includes the runbook, documentation, and a 30-day support window after go-live.

**Retainers.** For firms and fractional CFOs running multiple client stacks in production. Monthly retainer covers maintenance, integration monitoring, configuration changes when the chart of accounts or tool stack evolves, and a build allowance for new work.

**Audit and improvement.** For teams that already have integrations and automation in place but suspect the setup is not as clean or reliable as it should be. I review the current stack configuration, write up what works, what does not, and what specifically needs to change.

I do not sell hours and I do not sell seats. I sell working systems.

---

## Get in touch

- **Upwork:** [tabitha-eoke on Upwork](https://www.upwork.com/freelancers/~01954f73840469cae5)
- **LinkedIn:** [linkedin.com/in/tabitha-oke](https://www.linkedin.com/in/tabitha-oke-n8n)
- **Email:** tabithaeoke@gmail.com

If you manage client books and the stack is creating more reconciliation work than it saves, send a message describing the setup. You will get an honest answer on what is fixable, what is not, and what it would take. I respond within one business day.

---

## License

The workflows and code in this portfolio are published as portfolio pieces under the MIT License. Production deployment requires a direct engagement so the configuration, security, and compliance posture can be tailored to your specifics. See individual project folders for per-project license details.
