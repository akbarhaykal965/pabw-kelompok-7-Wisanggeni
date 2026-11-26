-- ============================================================================
-- 03_query.sql - Daftar Query Aplikasi ThriftHub (Kelompok Wisanggeni)
-- Berisi 6 query bisnis sesuai kebutuhan fitur & uji jalur ERD
-- ============================================================================
USE thrifthub;

-- Query 1
-- Pertanyaan bisnis : Produk thrift apa saja yang masih memiliki stok tersedia di tiap cabang toko atau gudang beserta kategorinya? (Uji jalur ERD)
-- Halaman / fitur   : Katalog Produk & Manajemen Stok Multi-Gudang
-- Teknik            : JOIN 4 tabel (produk -> kategori_produk -> stok_produk -> lokasi_gudang)
-- Jumlah baris      : 7 baris
SELECT p.kode_qr, p.nama_produk, k.nama_kategori, l.nama_lokasi, sp.jumlah_stok, p.harga_jual
FROM produk p
JOIN kategori_produk k ON p.kategori_id = k.kategori_id
JOIN stok_produk sp ON p.produk_id = sp.produk_id
JOIN lokasi_gudang l ON sp.lokasi_id = l.lokasi_id
WHERE sp.jumlah_stok > 0
ORDER BY l.nama_lokasi ASC, p.nama_produk ASC;

-- Query 2
-- Pertanyaan bisnis : Produk mana saja yang belum pernah masuk ke transaksi penjualan sama sekali (stok dead-stock)?
-- Halaman / fitur   : Laporan Evaluasi Stok & Rekomendasi Diskon Admin
-- Teknik            : LEFT JOIN dengan IS NULL (produk -> detail_transaksi)
-- Jumlah baris      : 2 baris
SELECT p.kode_qr, p.nama_produk, p.ukuran, p.harga_jual, k.nama_kategori
FROM produk p
JOIN kategori_produk k ON p.kategori_id = k.kategori_id
LEFT JOIN detail_transaksi dt ON p.produk_id = dt.produk_id
WHERE dt.transaksi_id IS NULL;

-- Query 3
-- Pertanyaan bisnis : Mitra konsinyasi mana saja yang memiliki akumulasi dana bagi hasil belum dicairkan minimal Rp100.000? (Uji jalur ERD)
-- Halaman / fitur   : Dashboard Pencairan Dana Mitra Konsinyasi
-- Teknik            : JOIN 3 tabel + GROUP BY + HAVING (pengguna -> konsinyasi -> bagi_hasil)
-- Jumlah baris      : 1 baris
SELECT u.nama AS nama_mitra,
       COUNT(bh.bagi_hasil_id) AS jumlah_item_terjual,
       SUM(bh.nominal_jual) AS total_omzet,
       SUM(bh.bagian_mitra) AS total_hak_mitra
FROM pengguna u
JOIN konsinyasi ks ON u.pengguna_id = ks.mitra_id
JOIN bagi_hasil bh ON ks.konsinyasi_id = bh.konsinyasi_id
WHERE bh.status_pencairan = 'BELUM_CAIR'
GROUP BY u.pengguna_id, u.nama
HAVING SUM(bh.bagian_mitra) >= 100000
ORDER BY total_hak_mitra DESC;

-- Query 4
-- Pertanyaan bisnis : Produk kategori premium apa saja yang masih tersedia dengan harga jual di atas rata-rata seluruh produk tersedia?
-- Halaman / fitur   : Etalase Rekomendasi Kurasi Premium (Beranda Pembeli)
-- Teknik            : Subquery skalar pada klausa WHERE
-- Jumlah baris      : 2 baris
SELECT kode_qr, nama_produk, ukuran, kondisi, harga_jual
FROM produk
WHERE harga_jual > (
    SELECT AVG(harga_jual)
    FROM produk
    WHERE status_produk = 'TERSEDIA'
)
AND status_produk = 'TERSEDIA'
ORDER BY harga_jual DESC;

-- Query 5
-- Pertanyaan bisnis : Bagaimana rekap seluruh riwayat transaksi POS maupun Online beserta nama pembeli (termasuk pelanggan walk-in) dan lokasi toko?
-- Halaman / fitur   : Riwayat Transaksi Kasir (POS) & Monitoring Penjualan Admin
-- Teknik            : LEFT JOIN (menangani pembeli_id NULL) + JOIN lokasi_gudang
-- Jumlah baris      : 6 baris
SELECT t.kode_transaksi, t.tanggal_transaksi, t.kanal,
       COALESCE(u.nama, 'Walk-In Customer') AS nama_pembeli,
       l.nama_lokasi, t.total_harga, t.status_pembayaran
FROM transaksi t
LEFT JOIN pengguna u ON t.pembeli_id = u.pengguna_id
JOIN lokasi_gudang l ON t.lokasi_id = l.lokasi_id
ORDER BY t.tanggal_transaksi DESC;

-- Query 6
-- Pertanyaan bisnis : Bagaimana jejak log perpindahan (mutasi) stok antar gudang/toko beserta petugas yang mencatatnya? (Uji jalur ERD)
-- Halaman / fitur   : Audit Log Mutasi Stok Gudang
-- Teknik            : JOIN multi-tabel & Self-Reference ke lokasi_gudang (asal & tujuan)
-- Jumlah baris      : 6 baris
SELECT ms.mutasi_id, ms.tanggal_mutasi, p.kode_qr, p.nama_produk,
       COALESCE(la.nama_lokasi, 'Barang Masuk Awal / Mitra') AS lokasi_asal,
       lt.nama_lokasi AS lokasi_tujuan,
       u.nama AS petugas_gudang, ms.jumlah
FROM mutasi_stok ms
JOIN produk p ON ms.produk_id = p.produk_id
LEFT JOIN lokasi_gudang la ON ms.lokasi_asal_id = la.lokasi_id
JOIN lokasi_gudang lt ON ms.lokasi_tujuan_id = lt.lokasi_id
JOIN pengguna u ON ms.petugas_id = u.pengguna_id
ORDER BY ms.tanggal_mutasi DESC;
