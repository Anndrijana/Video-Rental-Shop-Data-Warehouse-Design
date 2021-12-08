IF OBJECT_ID('Rental_fact', 'U') IS NOT NULL
DROP TABLE Rental_fact;

IF OBJECT_ID('Date_dim', 'U') IS NOT NULL 
DROP TABLE Date_dim;

IF OBJECT_ID('Customer_dim', 'U') IS NOT NULL
DROP TABLE Customer_dim;

IF OBJECT_ID('Staff_dim', 'U') IS NOT NULL
DROP TABLE Staff_dim;

IF OBJECT_ID('Store_dim', 'U') IS NOT NULL
DROP TABLE Store_dim;

IF OBJECT_ID('Film_dim', 'U') IS NOT NULL
DROP TABLE Film_dim;

IF OBJECT_ID('Category_dim', 'U') IS NOT NULL
DROP TABLE Category_dim;

IF OBJECT_ID('Actor_dim', 'U') IS NOT NULL
DROP TABLE Actor_dim;

CREATE TABLE Date_dim (
    [date_id] INT PRIMARY KEY, 
    [full_date] CHAR(10),
    [day_of_month] VARCHAR(2),
    [day_suffix] VARCHAR(4),
    [day_name] VARCHAR(9),
    [day_of_week] CHAR(1),
    [day_of_week_in_month] VARCHAR(2),
    [day_of_week_in_year] VARCHAR(2),
    [day_of_quarter] VARCHAR(3), 
    [day_of_year] VARCHAR(3),
    [week_of_month] VARCHAR(1),
    [week_of_quarter] VARCHAR(2),
    [week_of_year] VARCHAR(2),
    [month] VARCHAR(2),
    [month_name] VARCHAR(9),
    [month_of_quarter] VARCHAR(2),
    [quarter_name] VARCHAR(9),
    [year] CHAR(4),
    [month_year] CHAR(10)
)

DECLARE @start_date DATETIME = '2005-01-01'   
DECLARE @end_date DATETIME = '2007-01-01'

DECLARE
    @day_of_week_in_month INT,
    @day_of_week_in_year INT,
    @day_of_quarter INT,
    @week_of_month INT,
    @current_year INT,
    @current_month INT,
    @current_quarter INT

DECLARE @day_of_week TABLE
(
    DOW INT,
    MonthCount INT,
    QuarterCount INT,
    YearCount INT
)

INSERT INTO @day_of_week VALUES (1, 0, 0, 0)
INSERT INTO @day_of_week VALUES (2, 0, 0, 0)
INSERT INTO @day_of_week VALUES (3, 0, 0, 0)
INSERT INTO @day_of_week VALUES (4, 0, 0, 0)
INSERT INTO @day_of_week VALUES (5, 0, 0, 0)
INSERT INTO @day_of_week VALUES (6, 0, 0, 0)
INSERT INTO @day_of_week VALUES (7, 0, 0, 0)

DECLARE @current_date AS DATETIME = @start_date
SET @current_month = DATEPART(MM, @current_date)
SET @current_year = DATEPART(YY, @current_date)
SET @current_quarter = DATEPART(QQ, @current_date)

WHILE @current_date < @end_date
BEGIN
    IF @current_month != DATEPART(MM, @current_date) 
    BEGIN
        UPDATE @day_of_week
        SET [MonthCount] = 0
        SET @current_month = DATEPART(MM, @current_date)
    END

    IF @current_quarter != DATEPART(QQ, @current_date)
    BEGIN
        UPDATE @day_of_week
        SET [QuarterCount] = 0
        SET @current_quarter = DATEPART(QQ, @current_date)
    END

    IF @current_year != DATEPART(YY, @current_date)
    BEGIN
        UPDATE @day_of_week
        SET YearCount = 0
        SET @current_year = DATEPART(YY, @current_date)
    END

    UPDATE @day_of_week
    SET 
        MonthCount = MonthCount + 1,
        QuarterCount = QuarterCount + 1,
        YearCount = YearCount + 1
    WHERE DOW = DATEPART(DW, @current_date)

    SELECT
        @day_of_week_in_month = MonthCount,
        @day_of_quarter = QuarterCount,
        @day_of_week_in_year = YearCount
    FROM @day_of_week
    WHERE DOW = DATEPART(DW, @current_date)
    
    INSERT INTO Date_dim
    SELECT
        
        CONVERT (char(8),@current_date,112) as 'date_id',
        CONVERT (char(10),@current_date,101) as 'full_date',
        DATEPART(DD, @current_date) AS 'day_of_month',
        CASE 
            WHEN DATEPART(DD,@current_date) IN (11,12,13) THEN CAST(DATEPART(DD,@current_date) AS VARCHAR) + 'th'
            WHEN RIGHT(DATEPART(DD,@current_date),1) = 1 THEN CAST(DATEPART(DD,@current_date) AS VARCHAR) + 'st'
            WHEN RIGHT(DATEPART(DD,@current_date),1) = 2 THEN CAST(DATEPART(DD,@current_date) AS VARCHAR) + 'nd'
            WHEN RIGHT(DATEPART(DD,@current_date),1) = 3 THEN CAST(DATEPART(DD,@current_date) AS VARCHAR) + 'rd'
            ELSE CAST(DATEPART(DD,@current_date) AS VARCHAR) + 'th' 
        END AS 'day_suffix',
        
        DATENAME(DW, @current_date) AS 'day_name',
        DATEPART(DW, @current_date) AS 'day_of_week',
        @day_of_week_in_month AS 'day_of_week_in_month',
        @day_of_week_in_year AS 'day_of_week_in_year',
        @day_of_quarter AS 'day_of_quarter',
        DATEPART(DY, @current_date) AS 'day_of_year',
        DATEPART(WW, @current_date) + 1 - DATEPART(WW, CONVERT(VARCHAR, DATEPART(MM, @current_date)) + '/1/' + CONVERT(VARCHAR, DATEPART(YY, @current_date))) AS 'week_of_month',
        (DATEDIFF(DD, DATEADD(QQ, DATEDIFF(QQ, 0, @current_date), 0), @current_date) / 7) + 1 AS 'week_of_quarter',
        DATEPART(WW, @current_date) AS 'week_of_year',
        DATEPART(MM, @current_date) AS 'month',
        DATENAME(MM, @current_date) AS 'month_name',
        CASE
            WHEN DATEPART(MM, @current_date) IN (1, 4, 7, 10) THEN 1
            WHEN DATEPART(MM, @current_date) IN (2, 5, 8, 11) THEN 2
            WHEN DATEPART(MM, @current_date) IN (3, 6, 9, 12) THEN 3
        END AS 'Month_of_quarter',
        CASE DATEPART(QQ, @current_date)
            WHEN 1 THEN 'First'
            WHEN 2 THEN 'Second'
            WHEN 3 THEN 'Third'
            WHEN 4 THEN 'Fourth'
        END AS 'quarter_name',
        DATEPART(YEAR, @current_date) AS 'year',
        LEFT(DATENAME(MM, @current_date), 3) + '-' + CONVERT(VARCHAR, DATEPART(YY, @current_date)) AS 'month_year'

    SET @current_date = DATEADD(DD, 1, @current_date)
END

CREATE TABLE [Customer_dim] (
    [customer_id] float PRIMARY KEY,
    [customer_first_name] nvarchar(255),
    [customer_last_name] nvarchar(255),
    [customer_active] nvarchar(23),
    [customer_create_date] datetime,
    [customer_address] nvarchar(255),
    [customer_city] nvarchar(255),
    [customer_country] nvarchar(255),
    [customer_email] nvarchar(255)
)

CREATE TABLE [Staff_dim] (
    [staff_id] float PRIMARY KEY,
    [staff_first_name] nvarchar(255),
    [staff_last_name] nvarchar(255),
    [staff_active] nvarchar(20),
    [staff_address] nvarchar(255),
    [staff_city] nvarchar(255),
    [staff_country] nvarchar(255),
    [staff_email] nvarchar(255),
    [staff_username] nvarchar(255),
    [staff_password] nvarchar(255)
)

CREATE TABLE [Store_dim] (
    [store_id] float PRIMARY KEY,
    [store_address] nvarchar(255),
    [store_city] nvarchar(255),
    [store_country] nvarchar(255),
    [store_manager_first_name] nvarchar(255),
    [store_manager_last_name] nvarchar(255)
)

CREATE TABLE [Film_dim] (
    [film_id] float PRIMARY KEY,
    [film_title] nvarchar(255),
    [film_description] nvarchar(255),
    [film_release_year] float,
    [film_language] nvarchar(255),
    [film_rental_duration] nvarchar(54),
    [film_rental_rate_dollars] nvarchar(51),
    [film_duration] nvarchar(57),
    [film_replacement_cost_dollars] float,
    [film_rating_text] nvarchar(255)
)

CREATE TABLE [Category_dim] (
    [category_id] float PRIMARY KEY,
    [category_name] nvarchar(255)
)

CREATE TABLE [Actor_dim] (
    [actor_id] float PRIMARY KEY,
    [actor_first_name] nvarchar(255),
    [actor_last_name] nvarchar(255)
)

CREATE TABLE [Rental_fact] (
    [rental_id] float PRIMARY KEY,
    [customer_id] float FOREIGN KEY REFERENCES Customer_dim(customer_id),
    [staff_id] float FOREIGN KEY REFERENCES Staff_dim(staff_id),
    [rental_date_id] int FOREIGN KEY REFERENCES Date_dim(date_id),
    [return_date_id] int FOREIGN KEY REFERENCES Date_dim(date_id),
    [store_id] float FOREIGN KEY REFERENCES Store_dim(store_id),
    [film_id] float FOREIGN KEY REFERENCES Film_dim(film_id),
    [category_id] float FOREIGN KEY REFERENCES Category_dim(category_id),
    [actor_id] float FOREIGN KEY REFERENCES Actor_dim(actor_id),
    [customer_rental_duration] int,
    [customer_exceeded] nvarchar(35),
    [amount] float,
    [customer_overdraft_amount] float
)