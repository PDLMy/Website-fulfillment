CREATE DATABASE FulfilmentApp

USE FulfilmentApp

CREATE TABLE Users (
	User_ID BINARY NOT NULL PRIMARY KEY,
	Username VARCHAR(50) COLLATE Vietnamese_CI_AS NOT NULL UNIQUE,
	Password VARCHAR(255) NOT NULL,
	Avatar_Img VARCHAR(500) COLLATE Vietnamese_CI_AS NULL,
	Coin DECIMAL(18, 2) NOT NULL DEFAULT 0 CONSTRAINT CK_User_Coin_Non_Negative CHECK (coin >= 0),
	Fullname NVARCHAR(20) NOT NULL,
	Lastname NVARCHAR(20) NOT NULL,
	Birthday DATE NOT NULL,
)

-- Thành Phố
CREATE TABLE Provinces (
	Provinces_ID BINARY NOT NULL PRIMARY KEY,
	Name NVARCHAR(30) NOT NULL,
)

-- Phường
CREATE TABLE Wards (
	Wards_ID BINARY NOT NULL PRIMARY KEY,
	Name NVARCHAR(30) NOT NULL,
	Provinces_ID BINARY NOT NULL CONSTRAINT FK_Districts_Provinces
    FOREIGN KEY (Provinces_ID) REFERENCES Provinces(Provinces_ID),
)

CREATE TABLE User_addresses (
	ID BINARY NOT NULL PRIMARY KEY,
	User_ID BINARY NOT NULL CONSTRAINT FK_User_Address
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID),
	Provinces_ID BINARY NOT NULL CONSTRAINT FK_Provinces_Address
    FOREIGN KEY (Provinces_ID) REFERENCES Provinces(Provinces_ID),
	Wards_ID BINARY NOT NULL CONSTRAINT FK_Wards_Address
    FOREIGN KEY (Wards_ID) REFERENCES Wards(Wards_ID),
	Detail_Address NVARCHAR(255) NOT NULL
)

CREATE TRIGGER TR_Check_Birthday
ON Users
AFTER INSERT, UPDATE
AS
BEGIN
    -- Kiểm tra nếu có dòng nào vi phạm độ tuổi (ngoài khoảng từ trên 18 đến dưới 100)
    IF EXISTS (
        SELECT 1 FROM inserted 
        WHERE (
            DATEDIFF(YEAR, Birthday, GETDATE()) - 
            CASE 
                WHEN (MONTH(GETDATE()) < MONTH(Birthday)) 
                     OR (MONTH(GETDATE()) = MONTH(Birthday) AND DAY(GETDATE()) < DAY(Birthday)) 
                THEN 1 
                ELSE 0 
            END
        ) <= 18 OR (
            DATEDIFF(YEAR, Birthday, GETDATE()) - 
            CASE 
                WHEN (MONTH(GETDATE()) < MONTH(Birthday)) 
                     OR (MONTH(GETDATE()) = MONTH(Birthday) AND DAY(GETDATE()) < DAY(Birthday)) 
                THEN 1 
                ELSE 0 
            END
        ) >= 100
    )
    BEGIN
        RAISERROR (N'Lỗi: Tuổi nhân viên phải lớn hơn 18 và nhỏ hơn 100 tuổi!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;