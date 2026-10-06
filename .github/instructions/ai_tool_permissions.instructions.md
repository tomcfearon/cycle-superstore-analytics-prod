---
applyTo: "**/*.sql"
---
# AI Tool Permissions Policy

This file is authoritative for what the AI assistant is permitted to do autonomously
against each connected system. Read this whenever performing any database or infrastructure work.

---

## SQL Databases

### How the connection works
The VS Code MSSQL extension currently connects using the developer's **Azure Entra ID** identity.
A dedicated `ai_copilot` SQL authentication login is provisioned separately (see
`data_platform/admin/ai_copilot_user.sql`) and should be used via a dedicated connection profile
to enforce the permissions below at the database level. To enforce the AI user, remove the
Entra ID profiles from the MSSQL extension so only the `ai_copilot` profile is available.

### Per-database permission matrix

| Database | Profile | DB-level role | Writes |
|---|---|---|---|
| `css-dwh-dev` | Azure SQL DWH Dev — AI | `db_datareader` only | Blocked at DB level |
| `css-dwh-prod` | Azure SQL DWH Prod — AI | `db_datareader` only | Blocked at DB level |
| `CCData` (Store DB) | Store DB | `db_datareader` only | Blocked at DB level |
| `css2` (Web Server) | Web Server | `db_datareader` only | Blocked at DB level |

### Behavioural rules — the manual script workflow

- **SELECT** — always allowed, execute directly, no confirmation needed.
- **Everything else (INSERT, UPDATE, DELETE, DROP, TRUNCATE, CREATE, ALTER)** — **never execute directly.** Create a reviewed manual script in `data_platform/admin/` for security or environment administration, or `data_platform/scripts/maintenance/` for exceptional data and schema migrations; show it to the user and wait for them to run it manually.
- The only exception is one-off diagnostic/meta writes (e.g. resetting `meta.refresh_metadata`) where the user gives an explicit verbal instruction *and* confirms the SELECT result first — in that case, still prefer a manual script unless the user explicitly says "run it directly".

---

## Azure MCP

| Action category | Autonomous? |
|---|---|
| Read (list resources, config, costs) | Yes |
| Write config (app settings, scale rules) | Show plan, wait for confirmation |
| **Destructive (delete resource, drop DB, purge Key Vault)** | **Never without explicit confirmation** |

Intended RBAC: **Contributor** on dev resource group; **Reader** on prod unless a specific write task is in progress.

---

## Power BI MCP

Only used when the user explicitly requests it.

| Action | Autonomous? |
|---|---|
| Read model objects | Yes |
| Add / edit measures and columns | Yes — when instructed |
| Delete model objects | Show what will be deleted, wait for confirmation |

---

## The One Rule

> **AI may read and write freely. AI must never DELETE, DROP, TRUNCATE, or destroy data or
> infrastructure without first showing the user what will be affected and receiving an
> explicit "yes, proceed" confirmation.**
