-- =============================================================================
-- Project 3: Xero Payment Processor Reconciliation
-- File: 001_schema.sql
-- Purpose: Create the payment_recon schema, three tables, indexes, and the
--          two database-level triggers that enforce the compliance posture
--          (append-only posting_events, immutable identity fields on payouts).
-- Run against: Supabase (SQL editor)
-- Last updated: 2026-05-28
-- =============================================================================

-- Extensions ------------------------------------------------------------------
-- pgcrypto provides gen_random_uuid(). Supabase usually has it enabled, but
-- declare the dependency explicitly so this script is portable.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Schema ----------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS payment_recon;

-- =============================================================================
-- Table: payment_recon.payouts
-- Primary record per payout from either processor (Stripe or Shopify).
-- Identity fields are immutable after INSERT (enforced by trigger below).
-- =============================================================================
CREATE TABLE payment_recon.payouts (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_run_id         uuid NOT NULL,
    processor               text NOT NULL
                            CHECK (processor IN ('stripe', 'shopify')),
    payout_id               text NOT NULL,
    status                  text NOT NULL DEFAULT 'PENDING'
                            CHECK (status IN ('PENDING', 'POSTED', 'FAILED', 'SKIPPED_DUPLICATE')),
    failed_check            text,
    currency_code           character(3) NOT NULL DEFAULT 'USD'
                            CHECK (currency_code = 'USD'),
    gross_amount_minor      bigint NOT NULL DEFAULT 0,
    net_amount_minor        bigint NOT NULL DEFAULT 0,
    fee_amount_minor        bigint NOT NULL DEFAULT 0,
    refund_amount_minor     bigint NOT NULL DEFAULT 0,
    adjustment_amount_minor bigint NOT NULL DEFAULT 0,
    line_count              integer NOT NULL DEFAULT 0,
    lines_json              jsonb,
    xero_journal_id         text,
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now()
);

-- =============================================================================
-- Table: payment_recon.posting_events
-- Append-only event log. One row per state transition for a payout.
-- UPDATE and DELETE are blocked by trigger.
-- =============================================================================
CREATE TABLE payment_recon.posting_events (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    payout_uuid     uuid NOT NULL REFERENCES payment_recon.payouts(id),
    workflow_run_id uuid NOT NULL,
    event_type      text NOT NULL
                    CHECK (event_type IN ('RECEIVED', 'DECOMPOSED', 'VALIDATED', 'POSTED', 'FAILED', 'ERROR')),
    event_data      jsonb,
    created_at      timestamptz NOT NULL DEFAULT now()
);

-- =============================================================================
-- Table: payment_recon.account_map
-- Config table mapping (processor, transaction_type) to a Xero account code.
-- Editable without touching the workflow. Fetched live each run, never cached.
-- =============================================================================
CREATE TABLE payment_recon.account_map (
    id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    processor            text NOT NULL
                         CHECK (processor IN ('stripe', 'shopify')),
    transaction_type     text NOT NULL,
    xero_account_code    text NOT NULL,
    debit_or_credit      text NOT NULL
                         CHECK (debit_or_credit IN ('debit', 'credit')),
    description_template text NOT NULL,
    active               boolean NOT NULL DEFAULT true,
    created_at           timestamptz NOT NULL DEFAULT now(),
    updated_at           timestamptz NOT NULL DEFAULT now()
);

-- =============================================================================
-- Indexes
-- =============================================================================

-- Idempotency: only one row per (processor, payout_id). Re-running a payout
-- twice fails the INSERT and the workflow handles that as SKIPPED_DUPLICATE.
CREATE UNIQUE INDEX uq_payouts_processor_payout_id
    ON payment_recon.payouts (processor, payout_id);

-- Fast audit queries per workflow execution.
CREATE INDEX idx_payouts_workflow_run_id
    ON payment_recon.payouts (workflow_run_id);

-- Chronological audit timeline per payout.
CREATE INDEX idx_posting_events_payout_uuid_created_at
    ON payment_recon.posting_events (payout_uuid, created_at);

-- One ACTIVE mapping per (processor, transaction_type). Soft-retired rows
-- (active = false) coexist with their replacement.
CREATE UNIQUE INDEX uq_account_map_processor_transaction_type
    ON payment_recon.account_map (processor, transaction_type)
    WHERE active = true;

-- =============================================================================
-- Trigger 1: posting_events is append-only
-- UPDATE and DELETE both raise. INSERT is the only permitted operation.
-- This is the keystone control for the audit trail.
-- =============================================================================
CREATE OR REPLACE FUNCTION payment_recon.posting_events_append_only()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        RAISE EXCEPTION 'posting_events is append-only: UPDATE not permitted';
    END IF;
    IF (TG_OP = 'DELETE') THEN
        RAISE EXCEPTION 'posting_events is append-only: DELETE not permitted';
    END IF;
    RETURN NULL;
END;
$$;

CREATE TRIGGER trg_posting_events_append_only
    BEFORE UPDATE OR DELETE ON payment_recon.posting_events
    FOR EACH ROW EXECUTE FUNCTION payment_recon.posting_events_append_only();

-- =============================================================================
-- Trigger 2: payouts identity fields are immutable, DELETE is blocked
-- Allowed UPDATEs: status, failed_check, xero_journal_id, updated_at, and the
-- decomposed amount columns (the workflow itself writes these during the run).
-- Strictly immutable: workflow_run_id, processor, payout_id, currency_code,
-- created_at.
-- =============================================================================
CREATE OR REPLACE FUNCTION payment_recon.payouts_identity_immutable()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        RAISE EXCEPTION 'payouts: DELETE not permitted';
    END IF;
    IF (TG_OP = 'UPDATE') THEN
        IF NEW.workflow_run_id IS DISTINCT FROM OLD.workflow_run_id THEN
            RAISE EXCEPTION 'payouts.workflow_run_id is immutable';
        END IF;
        IF NEW.processor IS DISTINCT FROM OLD.processor THEN
            RAISE EXCEPTION 'payouts.processor is immutable';
        END IF;
        IF NEW.payout_id IS DISTINCT FROM OLD.payout_id THEN
            RAISE EXCEPTION 'payouts.payout_id is immutable';
        END IF;
        IF NEW.currency_code IS DISTINCT FROM OLD.currency_code THEN
            RAISE EXCEPTION 'payouts.currency_code is immutable';
        END IF;
        IF NEW.created_at IS DISTINCT FROM OLD.created_at THEN
            RAISE EXCEPTION 'payouts.created_at is immutable';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_payouts_identity_immutable
    BEFORE UPDATE OR DELETE ON payment_recon.payouts
    FOR EACH ROW EXECUTE FUNCTION payment_recon.payouts_identity_immutable();

-- =============================================================================
-- End of 001_schema.sql
-- Next: run 002_seed_account_map.sql to populate the initial account mappings.
-- =============================================================================
