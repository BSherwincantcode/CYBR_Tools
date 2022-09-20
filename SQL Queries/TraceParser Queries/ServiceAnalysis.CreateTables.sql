----- THIS SQL SCRIPT WILL -----
-- If tables don't exist, create tables
-- If tables do exist, deletes the tables and all data withn, then recreates with no data

-- Update to use correct schema
USE TRACE;

DROP TABLE IF EXISTS data_RAW;
DROP TABLE IF EXISTS data_parsed;

CREATE TABLE data_RAW (
	RAWDataID int NOT NULL AUTO_INCREMENT,
	TransactionID int,
	rawData text,
	PRIMARY KEY(RAWDataID)
);

CREATE TABLE data_parsed (
	ParseID int NOT NULL AUTO_INCREMENT,
	TransactionID int,
	ServiceName varchar(45),
	SafeFilter text,
	FileFilter text,
	CatIDs text,
	CatValues text,
	SearchInAllValues text,
    PRIMARY KEY(ParseID)
);