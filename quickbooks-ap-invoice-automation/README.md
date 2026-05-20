# QuickBooks AP Invoice Automation

End-to-end accounts payable automation for SMB finance teams running QuickBooks Online. From invoice intake to general ledger posting in under 90 seconds.

Full case study coming shortly. In the meantime, this folder contains:

- `workflows/` — the four n8n workflow JSON files (orchestrator, pre-posting gate, approval flow, error notifier)
- `samples/` — five test payload JSONs covering happy path, over-threshold approval, duplicate retry, authorisation failure, and chart of accounts failure
- `screenshots/` — eight screenshots from end-to-end testing showing the workflow graphs, Slack notifications, QuickBooks Bills posted, and Supabase audit log

For the portfolio overview and contact details, see the [portfolio root README](../README.md).
