-- OLTP -> staging
use master 
go

create database ChinookStaging

use ChinookStaging
go

select 
	[Chinook].[dbo].[Customer].CustomerId,
	[Chinook].[dbo].[Customer].FirstName,
	[Chinook].[dbo].[Customer].LastName,
	[Chinook].[dbo].[Customer].Company,
	[Chinook].[dbo].[Customer].Address,
	[Chinook].[dbo].[Customer].City,
	[Chinook].[dbo].[Customer].State,
	[Chinook].[dbo].[Customer].Country,
	[Chinook].[dbo].[Customer].PostalCode,
	[Chinook].[dbo].[Customer].Phone,
	[Chinook].[dbo].[Customer].Email,
	[Chinook].[dbo].[Customer].SupportRepId
	into [ChinookStaging].[dbo].[Customer]
from [Chinook].[dbo].[Customer]


--- staging ->DW

 
CREATE TABLE [ChinookStaging].[dbo].Staging_DimCustomer (
	   CustomerKey INT  IDENTITY(1,1)   
	,  CustomerId  int   NOT NULL
	,  CustomerFName  varchar(40)   NOT NULL
	,  CustomerLName  varchar(40)   NOT NULL
	,  CustomerCompany  varchar(100) NULL
	,  CustomerAddress varchar (300)  NULL
	,  CustomerCity varchar (300)  NULL
	,  CustomerState varchar (300)  NULL
	,  CustomerCountry varchar (300)  NULL
	,  CustomerPostal varchar (300)  NULL
	,  CustomerPhone varchar (50)  NULL
	,  CustomerEmail varchar (200) NOT NULL
	,  CustomerSupport int NULL
	,  RowIsCurrent  int   DEFAULT 1 NOT NULL
	,  RowStartDate  date DEFAULT '1899-12-31' NOT NULL
	,  RowEndDate  date  DEFAULT '9999-12-31' NOT NULL
	,  RowChangeReason  varchar(200)   NULL
);

------------------------------
Insert into [ChinookStaging].[dbo].Staging_DimCustomer([CustomerId], [CustomerFName],[CustomerLName], [CustomerCompany],[CustomerAddress],[CustomerCity],[CustomerState],[CustomerCountry],[CustomerPostal],[CustomerPhone],[CustomerEmail],[CustomerSupport])
	(Select [CustomerId], [FirstName],[LastName], [Company],[Address],[City],[State],[Country],[PostalCode],[Phone],[Email],[SupportRepId]
	from [ChinookStaging].[dbo].[Customer])

--ALTER TABLE Fa DROP CONSTRAINT FK__tblOrderH__Order__267ABA7A
----  [StagingNorth].[dbo].Staging_DimEmployee <--> NorthWindDW.dbo.DimEmployee
use ChinookDW
go

INSERT INTO [ChinookDW].[dbo].DimCustomer ([CustomerId], FirstName,LastName,Company,Address,City,State,Country,PostalCode,Phone,Email,SupportRepId, RowIsCurrent, RowStartDate, RowChangeReason )
SELECT [CustomerId]
      ,CustomerFName
	  ,CustomerLName
      ,CustomerCompany
	  ,CustomerAddress
	  ,CustomerCity
	  ,CustomerState
	  ,CustomerCountry
	  ,CustomerPostal
	  ,CustomerPhone
	  ,CustomerEmail
	  ,CustomerSupport
	  ,1
      ,CAST(GetDate() AS Date)
	  ,ActionName
FROM
(
	MERGE [ChinookDW].[dbo].DimCustomer AS target
		USING [ChinookStaging].[dbo].Staging_DimCustomer as source
		ON target.[CustomerId] = source.[CustomerId]
	 WHEN MATCHED 	 AND (source.[CustomerCompany] <> target.[Company] 
	 OR source.CustomerFName <> target.FirstName
	 OR source.CustomerLName <> target.LastName
	 OR source.CustomerAddress <> target.Address
	 OR source.CustomerCity <> target.City
	 OR source.CustomerState <> target.State
	 OR source.CustomerCountry <> target.Country
	 OR source.CustomerPostal <> target.PostalCode
	 OR source.CustomerPhone <> target.Phone
	 OR source.CustomerEmail <> target.Email
	 )  AND target.[RowIsCurrent] = 1 
	 THEN UPDATE SET
		 target.RowIsCurrent = 0,
		 target.RowEndDate = dateadd(day, -1, CAST(GetDate() AS Date)) ,
		 target.RowChangeReason = 'UPDATED NOT CURRENT'
	 WHEN NOT MATCHED THEN
	   INSERT  (
		   [CustomerId]
		,FirstName
		,LastName
		,Company
		,Address
		,City
		,State
		,Country
		,PostalCode
		,Phone
		,Email
		,SupportRepId
		,RowStartDate
		,RowChangeReason
	   )
	   VALUES( 
		   source.[CustomerId],  
		   source.CustomerFName,
		   source.CustomerLName,
		   source.CustomerCompany,
		   source.CustomerAddress,
		   source.CustomerCity,
		   source.CustomerState,
		   source.CustomerCountry,
		   source.customerPostal,
		   source.CustomerPhone,
		   source.CustomerEmail,
		   source.CustomerSupport,
		   CAST(GetDate() AS Date),
		   'NEW RECORD'
	   )
	WHEN NOT MATCHED BY Source THEN
		UPDATE SET 
			Target.RowEndDate= dateadd(day, -1, CAST(GetDate() AS Date))
			,target.RowIsCurrent = 0
			,Target.RowChangeReason  = 'SOFT DELETE'
	OUTPUT 
		source.[CustomerId],  
		   source.CustomerFName,
		   source.CustomerLName,
		   source.CustomerCompany,
		   source.CustomerAddress,
		   source.CustomerCity,
		   source.CustomerState,
		   source.CustomerCountry,
		   source.customerPostal,
		   source.CustomerPhone,
		   source.CustomerEmail,
		   source.CustomerSupport,
		   $Action as ActionName   
) AS Mrg
WHERE Mrg.ActionName='UPDATE'
AND [CustomerId] IS NOT NULL
