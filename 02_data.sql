-- ============================================================================
-- 02_data.sql - Data Contoh Basis Data ThriftHub (Kelompok Wisanggeni)
-- Jalankan setelah 01_skema_thrifthub.sql pada basis data kosong
-- ============================================================================
USE thrifthub;

-- 1. peran (5 baris)
INSERT INTO peran (peran_id, nama_peran) VALUES
 (1, 'ADMIN'),
 (2, 'KASIR'),
 (3, 'GUDANG'),
 (4, 'MITRA_KONSINYASI'),
 (5, 'PEMBELI');

-- 2. pengguna (8 baris - kolom no_hp memiliki nilai NULL pada pengguna 3 dan 7)
INSERT INTO pengguna (pengguna_id, nama, email, password_hash, no_hp, peran_id) VALUES
 (1, 'Raka Pratama', 'raka.admin@thrifthub.id', '$2y$10$hashadmin01', '081211110001', 1),
 (2, 'Nadia Putri', 'nadia.kasir@thrifthub.id', '$2y$10$hashkasir02', '081211110002', 2),
 (3, 'Dimas Saputra', 'dimas.gudang@thrifthub.id', '$2y$10$hashgudang03', NULL, 3),
 (4, 'Alya Maharani', 'alya.mitra@thrifthub.id', '$2y$10$hashmitra04', '081211110004', 4),
 (5, 'Bagas Wijaya', 'bagas.mitra@thrifthub.id', '$2y$10$hashmitra05', '081211110005', 4),
 (6, 'Citra Lestari', 'citra.buyer@gmail.com', '$2y$10$hashbuyer06', '081211110006', 5),
 (7, 'Fajar Nugroho', 'fajar.buyer@gmail.com', '$2y$10$hashbuyer07', NULL, 5),
 (8, 'Gita Permata', 'gita.buyer@gmail.com', '$2y$10$hashbuyer08', '081211110008', 5);

-- 3. kategori_produk (5 baris)
INSERT INTO kategori_produk (kategori_id, nama_kategori) VALUES
 (1, 'Jaket & Outerwear'),
 (2, 'Kemeja & Flanel'),
 (3, 'Kaos & Sweatshirt'),
 (4, 'Celana & Denim'),
 (5, 'Aksesoris & Topi');

-- 4. lokasi_gudang (5 baris)
INSERT INTO lokasi_gudang (lokasi_id, nama_lokasi, alamat, tipe_lokasi) VALUES
 (1, 'Gudang Pusat Kaliurang', 'Jl. Kaliurang Km 14, Sleman', 'GUDANG'),
 (2, 'Gudang Sortir Seturan', 'Jl. Seturan Raya No. 22, Sleman', 'GUDANG'),
 (3, 'Store Gejayan', 'Jl. Affandi Gejayan No. 18, Yogyakarta', 'TOKO'),
 (4, 'Store Jakal Bawah', 'Jl. Kaliurang Km 5 No. 45, Sleman', 'TOKO'),
 (5, 'Pop-Up Store Prawirotaman', 'Jl. Prawirotaman No. 10, Yogyakarta', 'TOKO');

-- 5. konsinyasi (5 baris)
INSERT INTO konsinyasi (konsinyasi_id, mitra_id, tanggal_titip, persen_komisi_toko, status_konsinyasi) VALUES
 (1, 4, '2026-10-01', 20.00, 'AKTIF'),
 (2, 5, '2026-10-05', 25.00, 'AKTIF'),
 (3, 4, '2026-10-12', 20.00, 'AKTIF'),
 (4, 5, '2026-10-20', 15.00, 'AKTIF'),
 (5, 4, '2026-11-01', 20.00, 'SELESAI');

-- 6. produk (8 baris - konsinyasi_id NULL untuk stok milik toko; produk 7 & 8 belum pernah terjual)
INSERT INTO produk (produk_id, kode_qr, nama_produk, ukuran, kondisi, harga_jual, status_produk, kategori_id, konsinyasi_id) VALUES
 (1, 'QR-TH-001', 'Jaket Denim Levi Vintage 90s', 'L', 'Grade A (95%)', 250000.00, 'TERJUAL', 1, 1),
 (2, 'QR-TH-002', 'Kemeja Flanel Uniqlo Kotak Merah', 'M', 'Like New (98%)', 120000.00, 'TERSEDIA', 2, NULL),
 (3, 'QR-TH-003', 'Crewneck Champion Reverse Weave', 'XL', 'Grade A (92%)', 185000.00, 'TERJUAL', 3, 2),
 (4, 'QR-TH-004', 'Celana Cargo Carhartt Workwear', '32', 'Grade B (88%)', 210000.00, 'TERSEDIA', 4, 3),
 (5, 'QR-TH-005', 'Windbreaker Nike Colorblock 90s', 'L', 'Grade A (94%)', 275000.00, 'TERJUAL', 1, 1),
 (6, 'QR-TH-006', 'Kaos Band Nirvana Reprint', 'L', 'Like New (97%)', 110000.00, 'TERSEDIA', 3, NULL),
 (7, 'QR-TH-007', 'Topi Corduroy Ralph Lauren Navy', 'All Size', 'Grade A (95%)', 95000.00, 'TERSEDIA', 5, 4),
 (8, 'QR-TH-008', 'Jaket Harrington Burberry Klasik', 'M', 'Grade A (93%)', 320000.00, 'TERSEDIA', 1, NULL);

-- 7. stok_produk (jembatan M:N - 10 baris >= 8 baris)
INSERT INTO stok_produk (produk_id, lokasi_id, jumlah_stok) VALUES
 (1, 3, 0),
 (2, 1, 2),
 (2, 3, 1),
 (3, 4, 0),
 (4, 1, 1),
 (4, 3, 1),
 (5, 3, 0),
 (6, 4, 2),
 (7, 2, 1),
 (8, 1, 1);

-- 8. mutasi_stok (6 baris - lokasi_asal_id NULL berarti penerimaan barang masuk awal)
INSERT INTO mutasi_stok (mutasi_id, produk_id, lokasi_asal_id, lokasi_tujuan_id, petugas_id, jumlah, tanggal_mutasi) VALUES
 (1, 1, NULL, 1, 3, 1, '2026-10-01 09:00:00'),
 (2, 1, 1, 3, 3, 1, '2026-10-02 10:30:00'),
 (3, 2, NULL, 1, 3, 3, '2026-10-03 11:00:00'),
 (4, 2, 1, 3, 3, 1, '2026-10-04 14:15:00'),
 (5, 3, NULL, 4, 3, 1, '2026-10-06 09:45:00'),
 (6, 5, 1, 3, 3, 1, '2026-10-10 16:00:00');

-- 9. transaksi (6 baris - pembeli_id NULL untuk walk-in POS; kasir_id NULL untuk checkout ONLINE)
INSERT INTO transaksi (transaksi_id, kode_transaksi, tanggal_transaksi, kanal, pembeli_id, kasir_id, lokasi_id, total_harga, status_pembayaran) VALUES
 (1, 'TRX-20261005-001', '2026-10-05 13:20:00', 'POS', NULL, 2, 3, 370000.00, 'LUNAS'),
 (2, 'TRX-20261008-002', '2026-10-08 19:45:00', 'ONLINE', 6, NULL, 4, 185000.00, 'LUNAS'),
 (3, 'TRX-20261012-003', '2026-10-12 15:10:00', 'POS', 7, 2, 3, 485000.00, 'LUNAS'),
 (4, 'TRX-20261015-004', '2026-10-15 20:05:00', 'ONLINE', 8, NULL, 3, 110000.00, 'LUNAS'),
 (5, 'TRX-20261020-005', '2026-10-20 11:30:00', 'POS', 6, 2, 4, 230000.00, 'LUNAS'),
 (6, 'TRX-20261102-006', '2026-11-02 17:50:00', 'ONLINE', 7, NULL, 3, 210000.00, 'PENDING');

-- 10. detail_transaksi (jembatan M:N - 9 baris >= 8 baris)
INSERT INTO detail_transaksi (transaksi_id, produk_id, jumlah, harga_satuan, subtotal) VALUES
 (1, 1, 1, 250000.00, 250000.00),
 (1, 2, 1, 120000.00, 120000.00),
 (2, 3, 1, 185000.00, 185000.00),
 (3, 5, 1, 275000.00, 275000.00),
 (3, 4, 1, 210000.00, 210000.00),
 (4, 6, 1, 110000.00, 110000.00),
 (5, 2, 1, 120000.00, 120000.00),
 (5, 6, 1, 110000.00, 110000.00),
 (6, 4, 1, 210000.00, 210000.00);

-- 11. bagi_hasil (5 baris untuk transaksi produk konsinyasi)
INSERT INTO bagi_hasil (bagi_hasil_id, transaksi_id, produk_id, konsinyasi_id, nominal_jual, bagian_toko, bagian_mitra, status_pencairan, tanggal_hitung) VALUES
 (1, 1, 1, 1, 250000.00, 50000.00, 200000.00, 'SUDAH_CAIR', '2026-10-05 13:25:00'),
 (2, 2, 3, 2, 185000.00, 46250.00, 138750.00, 'SUDAH_CAIR', '2026-10-08 19:50:00'),
 (3, 3, 5, 1, 275000.00, 55000.00, 220000.00, 'BELUM_CAIR', '2026-10-12 15:15:00'),
 (4, 3, 4, 3, 210000.00, 42000.00, 168000.00, 'BELUM_CAIR', '2026-10-12 15:15:00'),
 (5, 6, 4, 3, 210000.00, 42000.00, 168000.00, 'BELUM_CAIR', '2026-11-02 17:55:00');
