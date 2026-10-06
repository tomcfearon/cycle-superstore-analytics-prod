# Architectural Evolution: Enterprise Data Platform & Power BI

## 1. Executive Summary & Inception (2024)
This initiative modernized a legacy monolithic C# and SQL Server ecosystem dating back to 2002. The legacy architecture featured undocumented schemas, key-person dependencies, and tight coupling between operational ERP transactions and ad-hoc reporting. The objective was establishing a resilient, automated, and governed analytics platform.

-------

## 2. Platform Evolution Phases

### Phase 1: Source Discovery & Schema Reverse-Engineering
* **Action**: Mapped and documented tables, foreign keys, and implied relationships across the operational ERP database.
* **Outcome**: Established the initial semantic baseline and documented previously unrecorded entity relationships.

### Phase 2: Rapid Prototyping (Power Query / M)
* **Action**: Built an initial dimensional model utilizing Power Query with query folding targeting the source database.
* **Trade-off & Bottleneck**: As transformation complexity expanded, query folding broke down, resulting in expensive client-side compute, long refresh times, and compute pressure on the source engine.

### Phase 3: In-Database Transformation (SQL Views)
* **Action**: Re-engineered business logic out of Power Query into declarative T-SQL views on the primary SQL Server instance.
* **Outcome**: Improved query performance and introduced Git version control for transformation logic.
* **Bottleneck**: Large view queries created resource contention on active production ERP workloads during peak operational hours, and combining external web data sources across database boundaries remained computationally expensive.

### Phase 4: Cloud Data Warehouse Transition (Azure SQL & ADF)
* **Action**: Decoupled analytics workloads from operational databases by establishing a dedicated Azure SQL data warehouse populated via Azure Data Factory (ADF) ETL pipelines.
* **Outcome**: Completely eliminated operational database load and unified ERP and e-commerce streams into a single analytical repository.
* **Cost Efficiency**: Optimized compute by utilizing serverless auto-pause tiers, keeping monthly Azure SQL compute below €10/month for sub-terabyte volumes.

### Phase 5: Build Automation & Custom Lineage Tooling
* **Orchestration Pivot**: Assessed and tested dbt (Data Build Tool). Determined full dbt overhead was unwarranted for this specific architecture; replaced it with lightweight PowerShell automation to dynamically generate Graphviz DOT/SVG warehouse lineage diagrams.
* **State-Based Deployments**: Migrated database management to SQL Server Data Tools (SSDT) `.sqlproj` projects, introducing `.dacpac` state-based schema diff deployments.

### Phase 6: Enterprise CI/CD & Environment Isolation (January 2026)
* **Action**: Established multi-environment isolation (`Dev`, `Test`, `Prod`).
* **CI/CD Automation**: Implemented GitHub Actions workflows running automated DACPAC builds, disposable test database publishing/validation, and live PBIR report binding verifications on every Pull Request.
