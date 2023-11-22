# SQL "Ali Nino DB TASK"

## Task Description:
In this task we tried to create simple copy of [Ali Nino library website](https://alinino.az) database

Db name - AliNinoDb

Categories - Id. Title, ParentCategoryId(nullable) - reference Category(Id), IsDeleted (boolean)

Books - Id, Title, Description, ActualPrice, DiscountPrice(null),
  PublishingHouseId- reference PublishingHouses (Id),
StockCount, ArtcileCode, BindingId, Pages, CategoryId, IsDeleted (boolean)
 
Authors - Id, Name, Surname, IsDeleted (boolean)

BooksAuthors - Id, BookId, AuthorId

PublishingHouses - Id, Title, IsDeleted (boolean)

BooksGenres - Id, BookId, GenreId

Genres - Id, Title, IsDeleted (boolean)

Bindings - Id, Title, IsDeleted (boolean)

Languages - Id, Title, IsDeleted (boolean)

BooksLanguages- Id, BookId, LangueageId

Comments - Id, Description, BookId, Rating (check between 0 and 5), Name - not null, Email - not null,
ImageUrl - nvarchar, IsDeleted (boolean)


1) Your insert data and update data to tables must be done by Procedure.

2) Write trigger to update IsDelete  column of each table instead of delete.
