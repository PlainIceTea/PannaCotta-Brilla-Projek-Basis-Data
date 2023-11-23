CREATE DATABASE ProjectBD;


CREATE TABLE Pelanggan (
    ID_Pelanggan INT PRIMARY KEY IDENTITY(5000,1) NOT NULL,
    Nama_Pelanggan VARCHAR(255) NOT NULL,
    NoTelp_Pelanggan VARCHAR(20) NOT NULL,
    Alamat_Pelanggan VARCHAR(255) NOT NULL,
   
);


CREATE TABLE Menu (
    ID_Menu INT PRIMARY KEY IDENTITY(1000,1) NOT NULL,
    Nama_Menu VARCHAR(255),
    Harga_Satuan_Menu DECIMAL(10, 2)
);


CREATE TABLE Pesanan (
    ID_Pesanan INT PRIMARY KEY IDENTITY(2000,1)NOT NULL,
    ID_Pelanggan INT,
    Tanggal_Pengiriman DATE,
    Total_Pesanan DECIMAL(10, 2),
    FOREIGN KEY (ID_Pelanggan) REFERENCES Pelanggan(ID_Pelanggan),
   
);


CREATE TABLE Detail_Pesanan (
    ID_Pesanan INT,
    ID_Menu INT,
    Banyak_Barang INT,
    Jumlah DECIMAL(10, 2),
    PRIMARY KEY (ID_Pesanan, ID_Menu),
    FOREIGN KEY (ID_Pesanan) REFERENCES Pesanan(ID_Pesanan),
    FOREIGN KEY (ID_Menu) REFERENCES Menu(ID_Menu)
);

CREATE TABLE DetailPesananType 
(
    ID_Menu_T INT,
	Nama_Menu_T VARCHAR(255),
    Banyak_Barang_T INT
);

INSERT INTO Menu (Nama_Menu, Harga_Satuan_Menu)
VALUES
    ('Ayam Panggang Spesial', 30000.00),
    ('Patin Acar Kuning', 35000.00),
    ('Bandeng Presto', 25000.00),
    ('Rolade Daging Spesial', 38000.00),
    ('Soto Ayam Lezat', 17000.00),
    ('Ayam Teriyaki', 25000.00),
    ('Ayam Geprek Keju', 25000.00),
    ('Rendang Ayam', 17000.00),
    ('Pepes Tongkol', 28000.00),
    ('Ayam Tulang Lunak Spesial', 30000.00),
    ('Ayam Kremes Gurih', 30000.00),
    ('Sup Ayam Klaten', 17000.00),
    ('Bola Udang Istimewa', 30000.00),
    ('Sate Daging Manis', 32000.00),
    ('Ayam Lodho Khas Jawa', 25000.00),
    ('Gurame Asam Manis', 35000.00);
	

	
CREATE TRIGGER CalculateJumlah
ON Detail_Pesanan
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Update Jumlah pada setiap Detail_Pesanan yang baru ditambahkan
    UPDATE dp
    SET dp.Jumlah = dp.Banyak_Barang * m.Harga_Satuan_Menu
    FROM Detail_Pesanan dp
    INNER JOIN Menu m ON dp.ID_Menu = m.ID_Menu
    INNER JOIN inserted i ON dp.ID_Pesanan = i.ID_Pesanan
                       AND dp.ID_Menu = i.ID_Menu;
END;


CREATE TRIGGER UpdateTotalPesanan
ON Detail_Pesanan
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Update Total_Pesanan pada setiap Pesanan yang terpengaruh
    UPDATE p
    SET p.Total_Pesanan = (
        SELECT SUM(dp.Jumlah)
        FROM Detail_Pesanan dp
        WHERE dp.ID_Pesanan = p.ID_Pesanan
    )
    FROM Pesanan p
    INNER JOIN inserted i ON p.ID_Pesanan = i.ID_Pesanan;

    -- Optional: Menangani kasus ketika ada Pesanan yang tidak memiliki Detail_Pesanan
    UPDATE p
    SET p.Total_Pesanan = 0
    FROM Pesanan p
    WHERE p.ID_Pesanan IN (SELECT ID_Pesanan FROM deleted)
      AND NOT EXISTS (SELECT 1 FROM Detail_Pesanan WHERE ID_Pesanan = p.ID_Pesanan);
END;