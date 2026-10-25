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
	Created_at DATETIME2(0) NOT NULL CONSTRAINT DF_users_created_at DEFAULT SYSDATETIME(),
	Updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_users_updated_at DEFAULT SYSDATETIME(),
)

-- Thành Phố
CREATE TABLE Provinces (
	Provinces_ID BINARY NOT NULL PRIMARY KEY,
	Name NVARCHAR(30) NOT NULL,
	Created_at DATETIME2(0) NOT NULL CONSTRAINT DF_users_created_at DEFAULT SYSDATETIME(),
	Updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_users_updated_at DEFAULT SYSDATETIME(),
)

-- Phường
CREATE TABLE Wards (
	Wards_ID BINARY NOT NULL PRIMARY KEY,
	Name NVARCHAR(30) NOT NULL,
	Provinces_ID BINARY NOT NULL CONSTRAINT FK_Districts_Provinces
    FOREIGN KEY (Provinces_ID) REFERENCES Provinces(Provinces_ID),
	Created_at DATETIME2(0) NOT NULL CONSTRAINT DF_users_created_at DEFAULT SYSDATETIME(),
	Updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_users_updated_at DEFAULT SYSDATETIME(),
)

CREATE TABLE User_addresses (
	ID BINARY NOT NULL PRIMARY KEY,
	User_ID BINARY NOT NULL CONSTRAINT FK_User_Address
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID),
	Provinces_ID BINARY NOT NULL CONSTRAINT FK_Provinces_Address
    FOREIGN KEY (Provinces_ID) REFERENCES Provinces(Provinces_ID),
	Wards_ID BINARY NOT NULL CONSTRAINT FK_Wards_Address
    FOREIGN KEY (Wards_ID) REFERENCES Wards(Wards_ID),
	Detail_Address NVARCHAR(255) NOT NULL,
	Created_at DATETIME2(0) NOT NULL CONSTRAINT DF_users_created_at DEFAULT SYSDATETIME(),
	Updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_users_updated_at DEFAULT SYSDATETIME(),
)

CREATE TABLE Areas (
	ID BINARY NOT NULL PRIMARY KEY,
	Area_Name VARCHAR(2) NOT NULL UNIQUE,
	Created_at DATETIME2(0) NOT NULL CONSTRAINT DF_users_created_at DEFAULT SYSDATETIME(),
	Updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_users_updated_at DEFAULT SYSDATETIME(),
)

EXEC sp_rename 'Areas.ID', 'ID_Area', 'COLUMN';
EXEC sp_rename 'dbo.DF_users_created_at', 'DF_areas_created_at', 'OBJECT';
EXEC sp_rename 'dbo.DF_users_updated_at', 'DF_areas_updated_at', 'OBJECT';

CREATE TABLE Lines (
	ID BINARY NOT NULL PRIMARY KEY,
	Line_Number VARCHAR(2) NOT NULL,
	Area_Name VARCHAR(2) NOT NULL CONSTRAINT FK_Area_Lines
    FOREIGN KEY (Area_Name) REFERENCES Areas(Area_Name),
	Created_at DATETIME2(0) NOT NULL CONSTRAINT DF_users_created_at DEFAULT SYSDATETIME(),
	Updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_users_updated_at DEFAULT SYSDATETIME(),
)

EXEC sp_rename 'Lines.ID', 'ID_Line', 'COLUMN';
EXEC sp_rename 'dbo.DF_users_created_at', 'DF_line_created_at', 'OBJECT';
EXEC sp_rename 'dbo.DF_users_updated_at', 'DF_line_updated_at', 'OBJECT';

CREATE TABLE Floors (
	ID_Floor BINARY NOT NULL PRIMARY KEY,
	Floor_Number VARCHAR(2) NOT NULL,
	ID_Line BINARY NOT NULL CONSTRAINT FK_Line_Floors
    FOREIGN KEY (ID_Line) REFERENCES Lines(ID_Line),
	Created_at DATETIME2(0) NOT NULL CONSTRAINT DF_floor_created_at DEFAULT SYSDATETIME(),
	Updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_floor_updated_at DEFAULT SYSDATETIME(),
)

CREATE TABLE Location (
	ID_Location BINARY NOT NULL PRIMARY KEY,
	Location_Code VARCHAR(20) NOT NULL,
	Barcode VARCHAR(20) NOT NULL,
	Status VARCHAR(20) NOT NULL CHECK (Status IN ('EMPTY', 'OCCUPIED', 'MAINTENANCE', 'FULL')) Default 'EMPTY',
	Max_Weight DECIMAL NOT NULL,
	ID_Floor BINARY NOT NULL CONSTRAINT FK_Floor_Locations
    FOREIGN KEY (ID_Floor) REFERENCES Floors(ID_Floor),
)


CREATE TABLE Products (
    ID_Product BINARY NOT NULL PRIMARY KEY,
    Sku VARCHAR(50) NOT NULL UNIQUE,          -- Mã quản lý tồn kho (Stock Keeping Unit), ví dụ: 'PROD-A100'
    Barcode VARCHAR(100) NULL UNIQUE,         -- Mã vạch quét khi nhập/xuất (EAN-13, UPC, Code128)
    Name VARCHAR(255) NOT NULL,               -- Tên sản phẩm
    ID_Category INT NULL,                     -- FK đến bảng danh mục sản phẩm (nếu có)
    Unit VARCHAR(20) NOT NULL DEFAULT 'Cái',   -- Đơn vị tính: Cái, Thùng, Kg, Hộp,...
    
    -- Quy cách & Đặc tính vật lý (Rất quan trọng cho WMS để xếp vào Ô/Tầng phù hợp)
    Weight DECIMAL(10, 2) NULL,               -- Khối lượng trên 1 đơn vị (kg)
    Volume DECIMAL(10, 2) NULL,               -- Thể tích trên 1 đơn vị (m3 hoặc cm3)
    
    Status VARCHAR(20) NOT NULL CHECK (Status IN ('EMPTY', 'OCCUPIED', 'MAINTENANCE', 'FULL')) Default 'EMPTY',
    
	Created_at DATETIME2(0) NOT NULL CONSTRAINT DF_product_created_at DEFAULT SYSDATETIME(),
	Updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_product_updated_at DEFAULT SYSDATETIME(),

    -- Index hỗ trợ tìm kiếm nhanh
    INDEX idx_products_sku (sku),
    INDEX idx_products_barcode (barcode),
    INDEX idx_products_name (name)
);

CREATE TABLE Inventory (
    ID_Inventory BIGINT NOT NULL PRIMARY KEY,
    ID_Location BINARY NOT NULL CONSTRAINT FK_Location_Inventorys
    FOREIGN KEY (ID_Location) REFERENCES Location(ID_Location),                -- FK đến bảng locations (A-01-05-3)
    ID_Product BINARY NOT NULL CONSTRAINT FK_Product_Inventorys
    FOREIGN KEY (ID_Product) REFERENCES Products(ID_Product),                   -- FK đến bảng products
    Quantity INT NOT NULL DEFAULT 0,           -- Số lượng tồn kho hiện tại
    Reserved_Quantity INT NOT NULL DEFAULT 0,  -- Số lượng đã giữ chỗ (chờ xuất kho/đang đóng gói)
    Lot_Number VARCHAR(50) NULL,               -- Số lô sản xuất (Lot/Batch Number)
    Serial_Number VARCHAR(100) NULL,           -- Số Serial (nếu quản lý theo từng máy/thiết bị)
    Manufacture_Date DATE NULL,                -- Ngày sản xuất
    Expiry_Date DATE NULL,                     -- Hạn sử dụng (cho hàng thực phẩm/mỹ phẩm/dược phẩm)

	Min_stock INT DEFAULT 0,                  -- Mức tồn kho tối thiểu (Cảnh báo khi sắp hết)
    Max_stock INT DEFAULT 0,                  -- Mức tồn kho tối đa (Tránh nhập quá nhiều)

    Status VARCHAR(20) NOT NULL CHECK (Status IN ('EMPTY', 'OCCUPIED', 'MAINTENANCE', 'FULL')) DEFAULT 'AVAILABLE', -- Trạng thái hàng hóa
    Created_at DATETIME2(0) NOT NULL CONSTRAINT DF_inventory_created_at DEFAULT SYSDATETIME(),
	Updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_inventory_updated_at DEFAULT SYSDATETIME(),


    -- Index giúp tối ưu tốc độ truy vấn
    INDEX idx_inventory_location (ID_Location),
    INDEX idx_inventory_product (ID_Product),
    INDEX idx_inventory_lot (Lot_Number),
    INDEX idx_inventory_expiry (Expiry_Date)
);