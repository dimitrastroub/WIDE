use master
go

create database ChinookDW
go

use ChinookDW

go

CREATE TABLE [ChinookDW].[dbo].[DimCustomer](
	[CustomerKey] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[CustomerId] [int] NOT NULL,
	[FirstName] [nvarchar](40) NOT NULL,
	[LastName] [nvarchar](20) NOT NULL,
	[Company] [nvarchar](80) NULL,
	[Address] [nvarchar](70) NULL,
	[City] [nvarchar](40) NULL,
	[State] [nvarchar](40) NULL,
	[Country] [nvarchar](40) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[Phone] [nvarchar](24) NULL,
	[Email] [nvarchar](60) NOT NULL,
	[RowIsCurrent] INT DEFAULT 1 NOT NULL,     
	[RowStartDate] DATE DEFAULT '1899-12-31' NOT NULL,    
	[RowEndDate] DATE DEFAULT '9999-12-31' NOT NULL,     
	[RowChangeReason] varchar(200) NULL,
	[SupportRepId] [int] NULL
);

CREATE TABLE [ChinookDW].[dbo].[DimEmployee](
	[EmployeeKey] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[EmployeeId] [int] NOT NULL,
	[LastName] [nvarchar](20) NOT NULL,
	[FirstName] [nvarchar](20) NOT NULL,
	[Title] [nvarchar](30) NULL,
	[ReportsTo] [int] NULL,
	[BirthDate] [datetime] NULL,
	[HireDate] [datetime] NULL,
	[Address] [nvarchar](70) NULL,
	[City] [nvarchar](40) NULL,
	[State] [nvarchar](40) NULL,
	[Country] [nvarchar](40) NULL,
	[Phone] [nvarchar](24) NULL,
	[Email] [nvarchar](100) NULL,
	[RowIsCurrent] INT DEFAULT 1 NOT NULL,     
	[RowStartDate] DATE DEFAULT '1899-12-31' NOT NULL,    
	[RowEndDate] DATE DEFAULT '9999-12-31' NOT NULL,     
	[RowChangeReason] varchar(200) NULL
);

CREATE TABLE [ChinookDW].[dbo].[DimTrack](
	[TrackKey] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[TrackId] [int] NOT NULL,
	[ArtistName] [nvarchar](200) NOT NULL,
	[AlbumTitle] [nvarchar](200) NOT NULL,
	[TrackName] [nvarchar](200) NOT NULL,
	[Composer] [nvarchar](220) NULL,
	[Milliseconds] [int] NOT NULL,
	[Bytes] [int] NULL,
	[UnitPrice] [numeric](10, 2) NOT NULL,
	[MediaTypeName] [nvarchar](200) NOT NULL,
	[GenreName] [nvarchar](200) NOT NULL,	
	[NumPlaylist][int] NOT NULL,
	[RowIsCurrent] INT DEFAULT 1 NOT NULL,     
	[RowStartDate] DATE DEFAULT '1899-12-31' NOT NULL,    
	[RowEndDate] DATE DEFAULT '9999-12-31' NOT NULL,     
	[RowChangeReason] varchar(200) NULL
);


CREATE TABLE [ChinookDW].[dbo].[DimBilling](
	/*[InvoiceId] [int] NOT NULL,
	[CustomerId] [int] NOT NULL,
	[InvoiceDate] [datetime] NOT NULL,*/
	[BillingKey] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Billing_id][int] NOT NULL,
	[BillingAddress] [nvarchar](70) NULL,
	[BillingCity] [nvarchar](40) NULL,
	[BillingState] [nvarchar](40) NULL,
	[BillingCountry] [nvarchar](40) NULL,
	[BillingPostalCode] [nvarchar](10) NULL,
	[RowIsCurrent] INT DEFAULT 1 NOT NULL,     
	[RowStartDate] DATE DEFAULT '1899-12-31' NOT NULL,    
	[RowEndDate] DATE DEFAULT '9999-12-31' NOT NULL,     
	[RowChangeReason] varchar(200) NULL
);

CREATE TABLE [ChinookDW].[dbo].[FactInvoiceLine](
	/*[invoiceLineId][int] NOT NULL,*/
	[TrackKey][int] NOT NULL,
	/*[invoice_id][int] NOT NULL,*/ /*htan to idio me to Billing id ara peritto*/
	[InvoiceDate][int] NOT NULL,
	[CustomerKey][int] NOT NULL,
	[EmployeeKey][int] NOT NULL,
	[BillingKey][int] NOT NULL,
	[unit_price][numeric](10, 2) NOT NULL,
	[quantity][int] NOT NULL,
	
);

/*xwris inner*/
insert into [DimCustomer] (CustomerId,FirstName,LastName,Company,Address,City,State,Country,PostalCode,Phone,Email,SupportRepId)
select s.CustomerId, s.FirstName, s.LastName, s.Company, s.Address, s.City, s.State,s.Country, s.PostalCode, s.Phone, s.Email, s.SupportRepId from 
[StagingChinook].[dbo].[Customer] s

/*xwris inner*/
insert into [DimEmployee] (EmployeeId,LastName,FirstName,Title,ReportsTo,BirthDate,HireDate,Address,City,State,Country,Phone)
select a.EmployeeId, a.LastName, a.FirstName, a.Title, a.ReportsTo, a.BirthDate,a.HireDate, a.Address, a.City, a.State, a.Country, a.Phone from 
[StagingChinook].[dbo].[Employee] a

insert into [ChinookDW].[dbo].DimTrack(TrackId,ArtistName,AlbumTitle,TrackName,Composer,Milliseconds,Bytes,UnitPrice,MediaTypeName,GenreName,NumPlaylist)  
select c.TrackId,ar.Name ,a.Title, c.Name /*TrackName*/, c.Composer, c.Milliseconds, c.Bytes, c.UnitPrice, m.Name, g.Name, 1 from 
[StagingChinook].[dbo].[Track] c
inner join [StagingChinook].[dbo].Genre g on g.GenreId = c.GenreId
inner join [StagingChinook].[dbo].MediaType m on m.MediaTypeId = c.MediaTypeId
inner join [StagingChinook].[dbo].Album a on a.AlbumId = c.AlbumId
inner join [StagingChinook].[dbo].Artist ar on ar.ArtistId = a.ArtistId

/*
inner join [StagingChinook].[dbo].PlaylistTrack p on p.PlaylistId = c.TrackId
group by c.TrackId;*/

/*select *from DimTrack;*/
select * 
into [ChinookDW].[dbo]. DimDate
from [StagingChinook].dbo.DimDate;

alter table DimDate
add primary key  (DateKey) ;

UPDATE [ChinookDW].[dbo].DimTrack SET NumPlaylist = 
    ( SELECT COUNT(PlaylistId)
       FROM [StagingChinook].[dbo].PlaylistTrack pl
      WHERE [ChinookDW].[dbo].[DimTrack].TrackId = pl.TrackId 
    )

/*select *from DimTrack;*/
/*BillingTable*/


insert into [DimBilling](Billing_id,BillingAddress, BillingCity,BillingState,BillingCountry,BillingPostalCode)
select inv.InvoiceId, inv.BillingAddress, inv.BillingCity, inv.BillingState, inv.BillingCountry,inv.BillingPostalCode from [StagingChinook].[dbo].[Invoice] inv


/*FactTable*/

insert into [FactInvoiceLine](TrackKey,InvoiceDate,CustomerKey,EmployeeKey,BillingKey,unit_price,quantity)
select t.TrackId,d.DateKey, c.CustomerId,e.EmployeeId,inv.InvoiceId ,il.UnitPrice , il.Quantity from  [StagingChinook].[dbo].InvoiceLine il
inner join DimTrack t on t.TrackId = il.TrackId
inner join [StagingChinook].[dbo].Invoice inv on inv.InvoiceId = il.InvoiceId
inner join [StagingChinook].[dbo].Customer c on c.CustomerId = inv.CustomerId
inner join [StagingChinook].[dbo].Employee e on e.EmployeeId = c.SupportRepId
inner join [ChinookDW].[dbo].DimDate d on d.Date=inv.InvoiceDate

select * from FactInvoiceLine
 --ALTER TABLES AFTER SCD--

alter table FactInvoiceLine
add foreign key(InvoiceDate) references DimDate(DateKey)

alter table FactInvoiceLine
add foreign key(TrackKey) references DimTrack(TrackKey) 

alter table FactInvoiceLine
add foreign key(CustomerKey) references DimCustomer(CustomerKey)

alter table FactInvoiceLine
add foreign key(EmployeeKey) references DimEmployee(EmployeeKey)


alter table FactInvoiceLine
add foreign key(BillingKey) references DimBilling(BillingKey)






