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

CREATE TABLE Roles (
    Role_ID BINARY NOT NULL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL UNIQUE,
    Display_Name NVARCHAR(100),
    Description TEXT,
    Created_at DATETIME2(0) NOT NULL CONSTRAINT DF_role_created_at DEFAULT SYSDATETIME(),
	Updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_role_updated_at DEFAULT SYSDATETIME(),
)

CREATE TABLE User_Roles (
    User_ID BINARY NOT NULL,
    Role_ID BINARY NOT NULL,
    PRIMARY KEY (User_ID, Role_ID),
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID),
    FOREIGN KEY (Role_ID) REFERENCES Roles(Role_ID),
    Created_at DATETIME2(0) NOT NULL CONSTRAINT DF_user_roles_created_at DEFAULT SYSDATETIME(),
	Updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_user_roles_updated_at DEFAULT SYSDATETIME(),
)

CREATE TABLE Permissions (
    Permission_ID BINARY NOT NULL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL UNIQUE,
    Display_Name NVARCHAR(100),
    Module VARCHAR(50),
    Created_at DATETIME2(0) NOT NULL CONSTRAINT DF_permission_created_at DEFAULT SYSDATETIME(),
	Updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_permission_updated_at DEFAULT SYSDATETIME(),
)

CREATE TABLE Role_Permissions (
    Permission_ID BINARY NOT NULL,
    Role_ID BINARY NOT NULL,
    PRIMARY KEY (Permission_ID, Role_ID),
    FOREIGN KEY (Permission_ID) REFERENCES Permissions(Permission_ID),
    FOREIGN KEY (Role_ID) REFERENCES Roles(Role_ID),
    Created_at DATETIME2(0) NOT NULL CONSTRAINT DF_role_permissions_created_at DEFAULT SYSDATETIME(),
	Updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_role_permissions_updated_at DEFAULT SYSDATETIME(),
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
    ID_Inventory BINARY NOT NULL PRIMARY KEY,
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

CREATE TABLE Orders (
    ID_Order BINARY NOT NULL PRIMARY KEY,
    Order_Code VARCHAR(50) NOT NULL UNIQUE,     -- Mã đơn hàng hiển thị cho khách (VD: ORD-20261025-0001)
    Customer_Name VARCHAR(150) NOT NULL,        -- Tên khách hàng
    Customer_Phone VARCHAR(20) NOT NULL,        -- Số điện thoại khách hàng
    Shipping_Address NVARCHAR(500) NOT NULL,    -- Địa chỉ giao hàng
    
    -- Trạng thái đơn hàng
    OrderStatus VARCHAR(30) NOT NULL 
        CONSTRAINT CK_Orders_Status CHECK (OrderStatus IN ('PENDING', 'CONFIRMED', 'PACKING', 'SHIPPING', 'COMPLETED', 'CANCELLED')) 
        DEFAULT 'PENDING',
        
    -- Trạng thái thanh toán
    PaymentStatus VARCHAR(30) NOT NULL 
        CONSTRAINT CK_Orders_PaymentStatus CHECK (PaymentStatus IN ('UNPAID', 'PAID', 'REFUNDED')) 
        DEFAULT 'UNPAID',
        
    Total_Amount DECIMAL(18, 2) NOT NULL DEFAULT 0, -- Tổng giá trị đơn hàng
    
    Note NVARCHAR(500) NULL,                    -- Ghi chú của khách hàng
    
    Created_at DATETIME2(0) NOT NULL CONSTRAINT DF_orders_created_at DEFAULT SYSDATETIME(),
    Updated_at DATETIME2(0) NOT NULL CONSTRAINT DF_orders_updated_at DEFAULT SYSDATETIME(),

    -- Index tối ưu tìm kiếm theo mã đơn hoặc sdt khách
    INDEX idx_orders_code (Order_Code),
    INDEX idx_orders_phone (Customer_Phone),
    INDEX idx_orders_status (OrderStatus)
);

CREATE TABLE Order_Details (
    ID_OrderDetail BINARY NOT NULL PRIMARY KEY,
    ID_Order BINARY NOT NULL,                   -- FK đến bảng Orders
    ID_Product BINARY NOT NULL,                    -- FK đến bảng Products
    
    Quantity INT NOT NULL,                      -- Số lượng khách mua
    Unit_Price DECIMAL(18, 2) NOT NULL,         -- Giá bán của 1 sản phẩm tại thời điểm đặt hàng
    Sub_Total DECIMAL(18, 2) NOT NULL,          -- Thành tiền (= Quantity * Unit_Price)

    -- Ràng buộc khóa ngoại
    CONSTRAINT FK_Order_OrderDetails FOREIGN KEY (ID_Order) REFERENCES Orders(ID_Order) ON DELETE CASCADE,
    CONSTRAINT FK_Product_OrderDetails FOREIGN KEY (ID_Product) REFERENCES Products(ID_Product),

    -- Index tối ưu truy vấn
    INDEX idx_orderdetails_order (ID_Order),
    INDEX idx_orderdetails_product (ID_Product)
);

