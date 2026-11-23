CREATE DATABASE IF NOT EXISTS thrifthub
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE thrifthub;

-- 1. peran (RBAC)
CREATE TABLE peran (
  peran_id   INT AUTO_INCREMENT NOT NULL,
  nama_peran VARCHAR(40) NOT NULL,
  PRIMARY KEY (peran_id),
  CONSTRAINT uq_peran_nama UNIQUE (nama_peran)
) ENGINE=InnoDB;

-- 2. pengguna
CREATE TABLE pengguna (
  pengguna_id   INT AUTO_INCREMENT NOT NULL,
  nama          VARCHAR(100) NOT NULL,
  email         VARCHAR(100) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  no_hp         VARCHAR(20) NULL,
  peran_id      INT NOT NULL,
  PRIMARY KEY (pengguna_id),
  CONSTRAINT uq_pengguna_email UNIQUE (email),
  CONSTRAINT fk_pengguna_peran
    FOREIGN KEY (peran_id) REFERENCES peran(peran_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3. kategori_produk
CREATE TABLE kategori_produk (
  kategori_id   INT AUTO_INCREMENT NOT NULL,
  nama_kategori VARCHAR(60) NOT NULL,
  PRIMARY KEY (kategori_id),
  CONSTRAINT uq_kategori_nama UNIQUE (nama_kategori)
) ENGINE=InnoDB;

-- 4. lokasi_gudang
CREATE TABLE lokasi_gudang (
  lokasi_id   INT AUTO_INCREMENT NOT NULL,
  nama_lokasi VARCHAR(80) NOT NULL,
  alamat      VARCHAR(150) NOT NULL,
  tipe_lokasi VARCHAR(20) NOT NULL,
  PRIMARY KEY (lokasi_id),
  CONSTRAINT chk_lokasi_tipe CHECK (tipe_lokasi IN ('GUDANG', 'TOKO'))
) ENGINE=InnoDB;

-- 5. konsinyasi
CREATE TABLE konsinyasi (
  konsinyasi_id      INT AUTO_INCREMENT NOT NULL,
  mitra_id           INT NOT NULL,
  tanggal_titip      DATE NOT NULL,
  persen_komisi_toko DECIMAL(5,2) NOT NULL DEFAULT 20.00,
  status_konsinyasi  VARCHAR(20) NOT NULL DEFAULT 'AKTIF',
  PRIMARY KEY (konsinyasi_id),
  CONSTRAINT chk_konsinyasi_komisi CHECK (persen_komisi_toko >= 0 AND persen_komisi_toko <= 100),
  CONSTRAINT fk_konsinyasi_mitra
    FOREIGN KEY (mitra_id) REFERENCES pengguna(pengguna_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 6. produk
CREATE TABLE produk (
  produk_id     INT AUTO_INCREMENT NOT NULL,
  kode_qr       VARCHAR(50) NOT NULL,
  nama_produk   VARCHAR(120) NOT NULL,
  ukuran        VARCHAR(20) NOT NULL,
  kondisi       VARCHAR(30) NOT NULL,
  harga_jual    DECIMAL(12,2) NOT NULL,
  status_produk VARCHAR(20) NOT NULL DEFAULT 'TERSEDIA',
  kategori_id   INT NOT NULL,
  konsinyasi_id INT NULL,
  PRIMARY KEY (produk_id),
  CONSTRAINT uq_produk_qr UNIQUE (kode_qr),
  CONSTRAINT chk_produk_harga CHECK (harga_jual >= 0),
  CONSTRAINT fk_produk_kategori
    FOREIGN KEY (kategori_id) REFERENCES kategori_produk(kategori_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_produk_konsinyasi
    FOREIGN KEY (konsinyasi_id) REFERENCES konsinyasi(konsinyasi_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 7. stok_produk (jembatan M:N multi-gudang)
CREATE TABLE stok_produk (
  produk_id   INT NOT NULL,
  lokasi_id   INT NOT NULL,
  jumlah_stok INT NOT NULL DEFAULT 0,
  PRIMARY KEY (produk_id, lokasi_id),
  CONSTRAINT chk_stok_jumlah CHECK (jumlah_stok >= 0),
  CONSTRAINT fk_stok_produk
    FOREIGN KEY (produk_id) REFERENCES produk(produk_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_stok_lokasi
    FOREIGN KEY (lokasi_id) REFERENCES lokasi_gudang(lokasi_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 8. mutasi_stok
CREATE TABLE mutasi_stok (
  mutasi_id        INT AUTO_INCREMENT NOT NULL,
  produk_id        INT NOT NULL,
  lokasi_asal_id   INT NULL,
  lokasi_tujuan_id INT NOT NULL,
  petugas_id       INT NOT NULL,
  jumlah           INT NOT NULL,
  tanggal_mutasi   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (mutasi_id),
  CONSTRAINT chk_mutasi_jumlah CHECK (jumlah > 0),
  CONSTRAINT fk_mutasi_produk
    FOREIGN KEY (produk_id) REFERENCES produk(produk_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_mutasi_asal
    FOREIGN KEY (lokasi_asal_id) REFERENCES lokasi_gudang(lokasi_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_mutasi_tujuan
    FOREIGN KEY (lokasi_tujuan_id) REFERENCES lokasi_gudang(lokasi_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_mutasi_petugas
    FOREIGN KEY (petugas_id) REFERENCES pengguna(pengguna_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 9. transaksi (POS/Kasir & Checkout Online)
CREATE TABLE transaksi (
  transaksi_id      INT AUTO_INCREMENT NOT NULL,
  kode_transaksi    VARCHAR(40) NOT NULL,
  tanggal_transaksi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  kanal             VARCHAR(15) NOT NULL,
  pembeli_id        INT NULL,
  kasir_id          INT NULL,
  lokasi_id         INT NOT NULL,
  total_harga       DECIMAL(12,2) NOT NULL DEFAULT 0,
  status_pembayaran VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  PRIMARY KEY (transaksi_id),
  CONSTRAINT uq_transaksi_kode UNIQUE (kode_transaksi),
  CONSTRAINT chk_transaksi_total CHECK (total_harga >= 0),
  CONSTRAINT chk_transaksi_kanal CHECK (kanal IN ('POS', 'ONLINE')),
  CONSTRAINT fk_transaksi_pembeli
    FOREIGN KEY (pembeli_id) REFERENCES pengguna(pengguna_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_transaksi_kasir
    FOREIGN KEY (kasir_id) REFERENCES pengguna(pengguna_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_transaksi_lokasi
    FOREIGN KEY (lokasi_id) REFERENCES lokasi_gudang(lokasi_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 10. detail_transaksi (jembatan M:N transaksi & produk)
CREATE TABLE detail_transaksi (
  transaksi_id INT NOT NULL,
  produk_id    INT NOT NULL,
  jumlah       INT NOT NULL,
  harga_satuan DECIMAL(12,2) NOT NULL,
  subtotal     DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (transaksi_id, produk_id),
  CONSTRAINT chk_detail_jumlah CHECK (jumlah > 0),
  CONSTRAINT chk_detail_harga CHECK (harga_satuan >= 0),
  CONSTRAINT fk_dt_transaksi
    FOREIGN KEY (transaksi_id) REFERENCES transaksi(transaksi_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_dt_produk
    FOREIGN KEY (produk_id) REFERENCES produk(produk_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 11. bagi_hasil (otomatis untuk barang konsinyasi)
CREATE TABLE bagi_hasil (
  bagi_hasil_id    INT AUTO_INCREMENT NOT NULL,
  transaksi_id     INT NOT NULL,
  produk_id        INT NOT NULL,
  konsinyasi_id    INT NOT NULL,
  nominal_jual     DECIMAL(12,2) NOT NULL,
  bagian_toko      DECIMAL(12,2) NOT NULL,
  bagian_mitra     DECIMAL(12,2) NOT NULL,
  status_pencairan VARCHAR(20) NOT NULL DEFAULT 'BELUM_CAIR',
  tanggal_hitung   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (bagi_hasil_id),
  CONSTRAINT chk_bh_nominal CHECK (nominal_jual >= 0 AND bagian_toko >= 0 AND bagian_mitra >= 0),
  CONSTRAINT fk_bh_transaksi
    FOREIGN KEY (transaksi_id) REFERENCES transaksi(transaksi_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_bh_produk
    FOREIGN KEY (produk_id) REFERENCES produk(produk_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_bh_konsinyasi
    FOREIGN KEY (konsinyasi_id) REFERENCES konsinyasi(konsinyasi_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;