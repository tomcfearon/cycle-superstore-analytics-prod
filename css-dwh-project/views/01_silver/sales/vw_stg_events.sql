CREATE
-- OR ALTER
VIEW [stg].[events] AS
SELECT
    e.EventID AS event_id,
    e.EventType AS event_type,
    e.EventStatus AS event_status,
    e.IDCode AS id_code,
    e.StartDate AS start_date,
    e.EndDate AS end_date,
    e.SalesPerson AS employee_key,
    e.Urgent AS urgent,
    e.Event_Data1 AS event_data_1,
    e.Event_Data2 AS event_data_2,
    e.Event_Data3 AS event_data_3,
    e.Event_Data4 AS event_data_4,
    e.Event_Data5 AS event_data_5,
    e.Event_Data6 AS event_data_6
FROM
    [raw_ccdata].[Events] AS e