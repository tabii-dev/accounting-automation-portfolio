-- =============================================================================
-- Project 3: Xero Payment Processor Reconciliation
-- File: 002_seed_account_map.sql
-- Purpose: Seed payment_recon.account_map with the initial 12 rows
--          (6 Stripe transaction types + 6 Shopify transaction types).
-- Run against: Supabase (SQL editor), AFTER 001_schema.sql.
-- Last updated: 2026-05-28
--
-- IMPORTANT: verified against Clancy COA 2026-05-28; adjustment and reserve
-- accounts reassigned to Suspense (850) and Clearing Account (855).
-- To change a mapping after initial seed, INSERT a new active row + UPDATE
-- active = false on the old row; do not edit existing rows in place (the
-- workflow expects a stable history of account mappings).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Stripe rows (6)
-- -----------------------------------------------------------------------------

INSERT INTO payment_recon.account_map
    (processor, transaction_type, xero_account_code, debit_or_credit, description_template)
VALUES
    ('stripe', 'charge',          '200', 'credit',
     'Stripe gross sales for payout {payout_id}'),
    ('stripe', 'refund',          '200', 'debit',
     'Stripe refunds for payout {payout_id}'),
    -- payment / payment_refund: PaymentIntents-era equivalents of charge / refund.
    -- Unverified pending a real Stripe basket; mirror charge/refund mapping so the
    -- decomposer accepts either naming. Confirm on first real fixture.
    ('stripe', 'payment',         '200', 'credit',
     'Stripe gross sales for payout {payout_id}'),
    ('stripe', 'payment_refund',  '200', 'debit',
     'Stripe refunds for payout {payout_id}'),
    ('stripe', 'stripe_fee',      '404', 'debit',
     'Stripe processing fees for payout {payout_id}'),
    ('stripe', 'adjustment',      '850', 'debit',  -- Suspense, per Clancy COA 2026-05-28
     'Stripe adjustment for payout {payout_id}'),
    ('stripe', 'payout',          '090', 'debit',
     'Stripe payout to bank, {payout_id}'),
    ('stripe', 'transfer',        '850', 'debit',  -- Suspense, per Clancy COA 2026-05-28
     'Stripe transfer for payout {payout_id}');

-- -----------------------------------------------------------------------------
-- Shopify rows (6)
-- -----------------------------------------------------------------------------

INSERT INTO payment_recon.account_map
    (processor, transaction_type, xero_account_code, debit_or_credit, description_template)
VALUES
    ('shopify', 'charge',                      '200', 'credit',
     'Shopify gross sales for payout {payout_id}'),
    ('shopify', 'refund',                      '200', 'debit',
     'Shopify refunds for payout {payout_id}'),
    ('shopify', 'fee',                         '404', 'debit',
     'Shopify Payments fees for payout {payout_id}'),
    ('shopify', 'adjustment_reserve_hold',     '855', 'debit',  -- Clearing Account, per Clancy COA 2026-05-28
     'Shopify reserve hold for payout {payout_id}'),
    ('shopify', 'adjustment_reserve_release',  '855', 'credit',  -- Clearing Account, per Clancy COA 2026-05-28
     'Shopify reserve release for payout {payout_id}'),
    ('shopify', 'payout',                      '090', 'debit',
     'Shopify payout to bank, {payout_id}');

-- =============================================================================
-- End of 002_seed_account_map.sql
-- Sanity check (run separately):
--   SELECT processor, transaction_type, xero_account_code, debit_or_credit
--   FROM payment_recon.account_map
--   WHERE active = true
--   ORDER BY processor, transaction_type;
-- Expected: 14 rows (was 12 before payment/payment_refund were added).
-- =============================================================================
