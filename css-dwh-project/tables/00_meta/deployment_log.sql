CREATE TABLE [meta].[deployment_log]
(
    [log_id]            INT IDENTITY(1,1) NOT NULL CONSTRAINT [PK_deployment_log] PRIMARY KEY CLUSTERED,
    [deployment_date]   DATETIME2(3)      NOT NULL CONSTRAINT [DF_deployment_log_date] DEFAULT SYSUTCDATETIME(),
    [deployed_by]       NVARCHAR(128)     NOT NULL CONSTRAINT [DF_deployment_log_user] DEFAULT SUSER_SNAME(),
    [deployment_notes]  NVARCHAR(500)     NULL
);
GO
