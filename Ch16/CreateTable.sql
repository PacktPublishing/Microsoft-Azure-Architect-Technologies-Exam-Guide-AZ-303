CREATE TABLE Employee (
    Employeeid int IDENTITY(1,1) PRIMARY KEY,
    FirstName varchar(255) NOT NULL,
    LastName varchar(255) NOT NULL,
    Title varchar(255) NOT NULL,
    BirthDate date,
    HireDate date
);