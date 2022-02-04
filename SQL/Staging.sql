use master
go

create database StagingChinook
go

use StagingChinook

go

CREATE TABLE [dbo].[Album](
    [AlbumId] [int] NOT NULL,
    [Title] [nvarchar](160) NOT NULL,
    [ArtistId] [int] NOT NULL
    );

CREATE TABLE [dbo].[Artist](
    [ArtistId] [int] NOT NULL,
    [Name] [nvarchar](120) NULL
    );

CREATE TABLE [dbo].[Customer](
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
    /*[Fax] [nvarchar](24) NULL,*/
    [Email] [nvarchar](60) NOT NULL,
    [SupportRepId] [int] NULL
);


CREATE TABLE [dbo].[Employee](
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
    /*[PostalCode] [nvarchar](10) NULL,*/
    [Phone] [nvarchar](24) NULL,
    /*[Fax] [nvarchar](24) NULL,*/
    [Email] [nvarchar](60) NULL
);


CREATE TABLE [dbo].[Genre](
    [GenreId] [int] NOT NULL,
    [Name] [nvarchar](120) NULL
    );


CREATE TABLE [dbo].[Invoice](
    [InvoiceId] [int] NOT NULL,
    [CustomerId] [int] NOT NULL,
    [InvoiceDate] [datetime] NOT NULL,
    [BillingAddress] [nvarchar](70) NULL,
    [BillingCity] [nvarchar](40) NULL,
    [BillingState] [nvarchar](40) NULL,
    [BillingCountry] [nvarchar](40) NULL,
    [BillingPostalCode] [nvarchar](10) NULL,
    [Total] [numeric](10, 2) NOT NULL
    );


CREATE TABLE [dbo].[InvoiceLine](
    [InvoiceLineId] [int] NOT NULL,
    [InvoiceId] [int] NOT NULL,
    [TrackId] [int] NOT NULL,
    [UnitPrice] [numeric](10, 2) NOT NULL,
    [Quantity] [int] NOT NULL
    );


CREATE TABLE [dbo].[MediaType](
    [MediaTypeId] [int] NOT NULL,
    [Name] [nvarchar](120) NULL
    );


CREATE TABLE [dbo].[Playlist](
    [PlaylistId] [int] NOT NULL,
    [Name] [nvarchar](120) NULL
);


CREATE TABLE [dbo].[PlaylistTrack](
    [PlaylistId] [int] NOT NULL,
    [TrackId] [int] NOT NULL
    );



CREATE TABLE [dbo].[Track](
    [TrackId] [int] NOT NULL,
    [Name] [nvarchar](200) NOT NULL,
    [AlbumId] [int] NULL,
    [MediaTypeId] [int] NOT NULL,
    [GenreId] [int] NULL,
    [Composer] [nvarchar](220) NULL,
    [Milliseconds] [int] NOT NULL,
    [Bytes] [int] NULL,
    [UnitPrice] [numeric](10, 2) NOT NULL
    );


insert into [Album] (AlbumId, Title, ArtistId)
select c.AlbumId, c.Title, a.ArtistId from [Chinook].[dbo].[Album] c
inner join [Chinook].[dbo].Artist a on c.ArtistId=a.ArtistId;

insert into [Artist] (ArtistId, Name)
select ArtistId, Name from [Chinook].[dbo].Artist;

insert into [Playlist] (PlaylistId, Name) 
select PlaylistId, Name from [Chinook].[dbo].Playlist;

insert into [PlaylistTrack] (PlaylistId,TrackId)
select p.PlaylistId, p.TrackId from [Chinook].[dbo].PlaylistTrack p


insert into [Genre] (GenreId, Name)
select GenreId, Name from [Chinook].[dbo].Genre;

insert into [MediaType] (MediaTypeId, Name)
select MediaTypeId, Name from [Chinook].[dbo].MediaType;

insert into [Track] (TrackId, Name, AlbumId, MediaTypeId, GenreId,Composer,Milliseconds,Bytes,UnitPrice)
select TrackId, t.Name, a.AlbumId, m.MediaTypeId, g.GenreId,t.Composer,t.Milliseconds,t.Bytes,t.UnitPrice from [Chinook].[dbo].Track t
inner join [Chinook].[dbo].Album a on a.AlbumId=t.AlbumId
inner join [Chinook].[dbo].MediaType m on m.MediaTypeId=t.MediaTypeId
inner join [Chinook].[dbo].Genre g on g.GenreId=t.GenreId;

insert into [InvoiceLine] (InvoiceLineId, InvoiceId,TrackId,UnitPrice,Quantity)
select il.InvoiceLineId, i.InvoiceId,t.TrackId,il.UnitPrice,il.Quantity from [Chinook].[dbo].InvoiceLine il
inner join [Chinook].[dbo].Invoice i on i.InvoiceId=il.InvoiceId
inner join [Chinook].[dbo].Track t on t.TrackId=il.TrackId;


insert into Invoice (InvoiceId, CustomerId,InvoiceDate,BillingAddress,BillingCity,BillingState,BillingCountry,BillingPostalCode,Total)
select i.InvoiceId, c.CustomerId,i.InvoiceDate,i.BillingAddress,i.BillingCity,i.BillingState,i.BillingCountry,i.BillingPostalCode,i.Total from [Chinook].[dbo].Invoice i
inner join [Chinook].[dbo].Customer c on c.CustomerId=i.CustomerId;


insert into Customer (CustomerId,FirstName,LastName,Company,Address,City,State,Country,PostalCode,Phone,SupportRepId,Email)
select c.CustomerId,c.FirstName,c.LastName,c.Company,c.Address,c.City,c.State,c.Country,c.PostalCode,c.Phone, c.SupportRepId, c.Email from [Chinook].[dbo].Customer c
inner join [Chinook].[dbo].Employee e on e.EmployeeId=c.SupportRepId;

insert into Employee (EmployeeId,LastName,FirstName,Title,ReportsTo,BirthDate,HireDate,Address,City,State,Country,Phone)
select EmployeeId,LastName,FirstName,Title,ReportsTo,BirthDate,HireDate,Address,City,State,Country,Phone from [Chinook].[dbo].Employee;

select * from PlaylistTrack order by TrackId asc

select count(PlaylistId), TrackId from PlaylistTrack group by TrackId order by TrackId asc