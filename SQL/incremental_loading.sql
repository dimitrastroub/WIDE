use StagingChinook;
go

CREATE TABLE InvoiceLineVersionHistory(Version BIGINT,Date DATETIME);

ALTER TABLE InvoiceLine ADD Version ROWVERSION;


use ChinookDW
go


----------INCREMENTAL LOADING---------------

INSERT INTO [ChinookDW].[dbo].FactInvoiceLine
           ([TrackKey]
           ,[InvoiceDate]
           ,[CustomerKey]
           ,[EmployeeKey]
           ,[BillingKey]
           ,[unit_price]
           ,[quantity]
           )
     SELECT
           t.[TrackId]
           ,d.[DateKey]
           ,c.[CustomerId]
           ,e.[EmployeeId]
           ,inv.InvoiceId
           ,il.UnitPrice
           ,il.Quantity 
           
	from  [StagingChinook].[dbo].InvoiceLine il
	inner join DimTrack t on t.TrackId = il.TrackId
	inner join [StagingChinook].[dbo].Invoice inv on inv.InvoiceId = il.InvoiceId
	inner join [StagingChinook].[dbo].Customer c on c.CustomerId = inv.CustomerId
	inner join [StagingChinook].[dbo].Employee e on e.EmployeeId = c.SupportRepId
	inner join [ChinookDW].[dbo].DimDate d on d.Date=inv.InvoiceDate
	WHERE [version] >(SELECT MAX([version]) FROM StagingChinook.dbo.InvoiceLine);  --Incremental loading condition

select * from FactInvoiceLine;

	--SELECT * FROM FactInvoices;
use StagingChinook
go

-- then, update Version history in staging.. --

INSERT INTO StagingChinook.dbo.InvoiceLineVersionHistory(version, Date)
SELECT MAX([version]), GETDATE()
FROM StagingChinook.dbo.InvoiceLine;

--END OF INCREMENTAL LOADING-------------------------------------------------------------
