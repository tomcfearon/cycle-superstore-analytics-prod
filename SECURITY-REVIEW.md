# Security Review

**Review date:** 2026-10-09  
**Scope:** Static security review of the repository.

## Findings

### 🟠 HIGH — Xero credentials and tokens may be exposed in ADF activity runs

- **File:** `data_platform/adf/pipeline/6_Xero Finance.json`
- **Lines:** 13-14, 41-42, 70-71, 101-102, 225-237
- **Confidence:** 9/10
- **Issue:** Key Vault secret retrieval, OAuth token exchange, and Xero request activities have `secureOutput` and/or `secureInput` disabled. Activity-run details may therefore expose secret values, token responses, or bearer-token inputs to principals permitted to inspect those runs.
- **Impact:** Anyone able to access exposed run details could potentially reuse credentials or tokens to access Xero financial data.
- **Recommendation:** Enable secure output for activities returning secrets or tokens, and secure input for activities whose inputs contain credentials or bearer tokens. Review access to activity-run details and rotate credentials if exposure is confirmed.
- **Limitations:** The repository does not establish live ADF role assignments or run-history retention, so exposure to a specific principal and any past access could not be confirmed.
