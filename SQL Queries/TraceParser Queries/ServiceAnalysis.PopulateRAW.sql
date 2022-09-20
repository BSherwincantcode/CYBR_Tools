-- Ensure the schema (trace) and table name (trace20220215163952) are accurate
-- Update the "WHERE" clause to retrieve the smallest dataset you need, as the parsing is an intesive operation and less data is better

INSERT INTO data_RAW(transactionID,rawdata)
SELECT transactionID,data FROM trace.trace20220215163952
WHERE
    ServiceName = 'FindFilesServ' AND
    (   UserName ='User1' OR 
        Username = 'User2' OR 
        UserName = 'User3'
    )