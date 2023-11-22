--Task begins
CREATE DATABASE AliNinoDB
GO
USE AliNinoDB
GO
CREATE TABLE Categories 
(
	Id int identity primary key,
	Title varchar(30) NOT NULL,
	ParentId int references Categories(Id),
	IsDeleted bit DEFAULT 0
)
CREATE TABLE Authors
(
	Id int identity primary key,
	Name nvarchar(30) NOT NULL,
	Surname nvarchar(30) NOT NULL,
	IsDeleted bit DEFAULT 0
)
CREATE TABLE Genres
(
	Id int identity primary key,
	Title varchar(30) NOT NULL,
	IsDeleted bit DEFAULT 0
)
CREATE TABLE Languages
(
	Id int identity primary key,
	Title nvarchar(30) NOT NULL,
	IsDeleted bit DEFAULT 0
)
CREATE TABLE PublishingHouse
(
	Id int identity primary key,
	Title nvarchar(30) NOT NULL,
	IsDeleted bit DEFAULT 0
)
CREATE TABLE Bindings
(
	Id int identity primary key,
	Title varchar(30) NOT NULL,
	IsDeleted bit DEFAULT 0
)
CREATE TABLE Books
(
	Id int identity primary key,
	Title nvarchar(30) NOT NULL,
	Description nvarchar(255) NOT NULL,
	ActualPrice money NOT NULL,
	DiscountPrice money,
	PublishingHouseID int references PublishingHouse(Id) NOT NULL,
	StockCount int,
	ArticalCode int unique NOT NULL,
	BindingID int references Bindings(Id) NOT NULL,
	Pages int NOT NULL,
	CategoryID int references Categories(Id) NOT NULL,
	IsDeleted bit DEFAULT 0,
	CHECK(DiscountPrice < ActualPrice)
)
CREATE TABLE Comments
(
	Id int identity primary key,
	Description nvarchar(255) NOT NULL,
	BookID int references Books(Id) NOT NULL,
	Rate int CHECK(Rate between 0 and 5),
	Name nvarchar(30) NOT NULL,
	Email nvarchar(30) NOT NULL,
	ImageUrl nvarchar(30),
	IsDeleted bit DEFAULT 0
)
CREATE TABLE BooksAuthors
(
	Id int identity primary key,
	BookID int references Books(Id),
	AuthorID int references Authors(Id),
	IsDeleted bit DEFAULT 0
)
CREATE TABLE BooksGenres
(
	Id int identity primary key,
	BookID int references Books(Id),
	GenreID int references Genres(Id),
	IsDeleted bit DEFAULT 0
)
CREATE TABLE BooksLanguages
(
	Id int identity primary key,
	BookID int references Books(Id),
	LanguageID int references Languages(Id),
	IsDeleted bit DEFAULT 0
)
-- INSERTS
CREATE PROCEDURE CreateCategory 
(
@Title varchar(30), 
@ParentTitle varchar(30)
)
AS
BEGIN
	DECLARE @ParentID int 
	SET @ParentID = 
	(
		SELECT Id FROM Categories WHERE Categories.Title = @ParentTitle
	)
	
	INSERT INTO Categories (Title, ParentId) VALUES (@Title, @ParentID)
END

CREATE PROCEDURE CreateBook
( 
@Title nvarchar(30),
@Description nvarchar(255),
@ActualPrice money, 
@Discount float,
@PublishingHouse nvarchar(30), 
@StockCount int,
@ArticalCode varchar(30), 
@Binding varchar(30),
@Pages int, 
@Category varchar(30)
)
AS
BEGIN
	IF NOT EXISTS (SELECT PublishingHouse.Title FROM PublishingHouse WHERE PublishingHouse.Title = @PublishingHouse)
		INSERT INTO PublishingHouse (Title) VALUES (@PublishingHouse)
	IF NOT EXISTS (SELECT Bindings.Title FROM Bindings WHERE Bindings.Title = @Binding)
		INSERT INTO Bindings (Title) VALUES (@Binding)
	IF NOT EXISTS (SELECT Categories.Title FROM Categories WHERE Categories.Title = @Category)
		EXEC dbo.CreateCategory @Title = @Category, @ParentTitle= 'book'
	INSERT INTO Books (Title, Description, ActualPrice, DiscountPrice, ArticalCode, Pages, StockCount, PublishingHouseID, BindingID, CategoryID) 
	VALUES (@Title, @Description, @ActualPrice, @ActualPrice - ((@Discount*@ActualPrice)/100), @ArticalCode, @Pages, @StockCount, (SELECT PublishingHouse.Id FROM PublishingHouse WHERE PublishingHouse.Title = @PublishingHouse), (SELECT Bindings.Id FROM Bindings WHERE Bindings.Title = @Binding), (SELECT Categories.Id FROM Categories WHERE Categories.Title = @Category))
END

CREATE PROCEDURE AddGenreToBook
(
@Book nvarchar(30),
@Genre varchar(30)
)
AS
BEGIN
	IF NOT EXISTS (SELECT Books.Title FROM Books WHERE Books.Title = @Book)
		print('There is no such book')
		RETURN
	IF NOT EXISTS (SELECT Genres.Title FROM Genres WHERE Genres.Title = @Genre)
		INSERT INTO Genres (Title) VALUES (@Genre)
	INSERT INTO BooksGenres (BookID, GenreID) VALUES ((SELECT Books.Id FROM Books WHERE Books.Title = @Book), (SELECT Genres.Id FROM Genres WHERE Genres.Title = @Genre))
END

CREATE PROCEDURE AddAuthorToBook
(
@Book nvarchar(30),
@AuthorName nvarchar(30),
@AuthorSurname nvarchar(30)
)
AS
BEGIN
	IF NOT EXISTS (SELECT Books.Title FROM Books WHERE Books.Title = @Book)
		print('There is no such book')
		RETURN
	IF NOT EXISTS (SELECT Authors.Name, Authors.Surname FROM Authors WHERE Authors.Name = @AuthorName and Authors.Surname = @AuthorSurname)
		INSERT INTO Authors(Name, Surname) VALUES (@AuthorName, @AuthorSurname)
	INSERT INTO BooksAuthors (BookID, AuthorID) VALUES ((SELECT Books.Id FROM Books WHERE Books.Title = @Book), (SELECT Authors.Id FROM Authors WHERE Authors.Name = @AuthorName and Authors.Surname = @AuthorSurname))
END

CREATE PROCEDURE AddLanguageToBook
(
@Book nvarchar(30),
@Language nvarchar(30)
)
AS
BEGIN
	IF NOT EXISTS (SELECT Books.Title FROM Books WHERE Books.Title = @Book)
		print('There is no such book')
		RETURN
	IF NOT EXISTS (SELECT Languages.Title FROM Languages WHERE Languages.Title = @Language)
		INSERT INTO Languages (Title) VALUES (@Language)
	INSERT INTO BooksLanguages (BookID, LanguageID) VALUES ((SELECT Books.Id FROM Books WHERE Books.Title = @Book), (SELECT Languages.Id FROM Languages WHERE Languages.Title = @Language))
END

CREATE PROCEDURE AddCommentToBook
(
@Book nvarchar(30),
@Description nvarchar(255),
@Name nvarchar(30),
@Email varchar(30),
@ImageUrl nvarchar(30),
@Rate int
)
AS
BEGIN
	IF NOT EXISTS (SELECT Books.Title FROM Books WHERE Books.Title = @Book)
		print('There is no such book')
		RETURN
	INSERT INTO Comments (Description, BookID, Name, Email, ImageUrl, Rate) VALUES (@Description, (SELECT Books.Id FROM Books WHERE Books.Title = @Book), @Name, @Email, @ImageUrl, @Rate)
END

--Updates

CREATE PROCEDURE UpdateBook
( 
  @Title nvarchar(30),
  @Description nvarchar(255),
  @ActualPrice money, 
  @Discount float,
  @PublishingHouse nvarchar(30), 
  @StockCount int,
  @ArticalCode varchar(30), 
  @Binding varchar(30),
  @Pages int, 
  @Category varchar(30)
)
AS
BEGIN
  IF NOT EXISTS (SELECT PublishingHouse.Title FROM PublishingHouse WHERE PublishingHouse.Title = @PublishingHouse)
		INSERT INTO PublishingHouse (Title) VALUES (@PublishingHouse)
	IF NOT EXISTS (SELECT Bindings.Title FROM Bindings WHERE Bindings.Title = @Binding)
		INSERT INTO Bindings (Title) VALUES (@Binding)
	IF NOT EXISTS (SELECT Categories.Title FROM Categories WHERE Categories.Title = @Category)
		EXEC dbo.CreateCategory @Title = @Category, @ParentTitle= 'book'

  UPDATE Books
  SET
    Description = @Description,
    ActualPrice = @ActualPrice,
    DiscountPrice = @ActualPrice - ((@Discount * @ActualPrice) / 100),
    ArticalCode = @ArticalCode,
    Pages = @Pages,
    StockCount = @StockCount,
    PublishingHouseID = (SELECT Id FROM PublishingHouse WHERE Title = @PublishingHouse),
    BindingID = (SELECT Id FROM Bindings WHERE Title = @Binding),
    CategoryID = (SELECT Id FROM Categories WHERE Title = @Category)
  WHERE
    Title = @Title;
END

CREATE PROCEDURE UpdateComment
(
  @Id int,
  @Description nvarchar(255),
  @ImageUrl nvarchar(30),
  @Rate int
)
AS
BEGIN
  IF NOT EXISTS (SELECT Comments.Id FROM Comments WHERE Id = @Id)
  BEGIN
    PRINT('There is no such comment');
    RETURN;
  END

  UPDATE Comments
  SET
    Description = @Description,
    ImageUrl = @ImageUrl,
    Rate = @Rate
  WHERE
    Id = @Id;
END

--qalanlar mence menasizdir, eyni fikrinde deyilsizse sadece balimi kesin
-- TRIGGERS

CREATE TRIGGER InsteadOfDeleteTrigger
ON Books
INSTEAD OF DELETE
AS
BEGIN
	UPDATE Books
	SET IsDeleted = 1
    FROM deleted
    WHERE Books.Id = deleted.Id;
END


-- qalanlari da eyni mentiqiynen yaziriq
