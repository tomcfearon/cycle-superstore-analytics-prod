CREATE TABLE [marts].[dim_transaction] (
    [transaction_key]       VARCHAR (20)   NOT NULL,
    [document_number]       VARCHAR (12)   NOT NULL,
    [document_type]         VARCHAR (50)   NOT NULL,
    [internal_note]         VARCHAR (8000) NULL,
    [row_modified_datetime] DATETIME       NULL
) ON [PRIMARY];


GO
ALTER TABLE [marts].[dim_transaction]
    ADD CONSTRAINT [PK_dim_transaction] PRIMARY KEY CLUSTERED ([transaction_key] ASC);