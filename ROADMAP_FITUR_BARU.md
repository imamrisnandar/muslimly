# Roadmap Fitur Baru Muslimly

> Draft untuk direview. **Status kode (2026-11-10): Gelombang 1 Fase 0–6 sudah dikode dan lolos unit test + kompilasi Android; belum diuji di perangkat, belum ada tinjauan ustadz.** Lihat bagian "Status implementasi Gelombang 1" di bawah.
> **Satu-satunya dokumen rencana fitur baru.** Bagian I = rencana rinci Gelombang 1 (lintang tinggi, widget Android, tracker sholat, qadha). Bagian II = fitur lain (Gelombang 2–5).
> Klaim yang belum bisa saya verifikasi ditandai **[belum diverifikasi]**. Angka dan aturan fiqh/zakat **wajib ditinjau** sebelum rilis.

## Keputusan yang sudah diambil

- **Widget:** Android dulu; iOS (WidgetKit + Live Activity) ditunda sampai ada device uji.
- **Qadha:** pencatatan **plus wizard** perkiraan utang lama.
- **Data uzur (haid/nifas/sakit):** lokal saja, tidak di-sync; pengingat tetap berjalan lokal.
- **Gelombang 2** (Ramadan/khatam, zakat, tasbih + Asmaul Husna + hadis) disetujui sebelum musafir.
- **Peninjauan konten fiqh dan hadis:** oleh Anda, setelah konsultasi ke ustadz. Ini syarat rilis.
- **Murajaah:** sudah ada di kode, bukan item baru.
- **Zakat — standar nisab bawaan: emas 24 karat (85 gram), haul 1 tahun.** Nisab zakat penghasilan versi BAZNAS (acuan 14 karat) **ditunda** sampai Anda berkonsultasi dengan ustadz; sementara itu perhitungan memakai nisab emas 24 karat dengan haul 1 tahun.
- **Harga emas 24 karat: diperbarui otomatis, mingguan,** oleh backend (§4). Antam/Logam Mulia tidak dipakai (memblokir akses otomatis).
- **Tajwid:** disetujui dijadikan **spike dulu** (§6), bukan fitur yang dijanjikan.
- **Halal scanner:** Satu Data BPJPH sudah dicek (§5); tidak ada data per produk, jadi v1 hanya membuka sumber resmi.

## Status tiap item dari daftar Anda

| Item | Status di kode | Keputusan |
|---|---|---|
| Waktu sholat lintang tinggi | Belum ada | Bagian I, **Fase 0** |
| Murajaah terjadwal (Leitner) | **Sudah ada** (`muraja_ah_scheduler.dart`, notifikasi di job harian, tabel `hafalan_sessions`) | **Bukan item baru.** Cukup verifikasi di device; tidak ada rencana baru |
| Perencana Ramadan & khatam | Ada target baca harian dan statistik baca, belum ada rencana khatam | Rencana di §1 |
| Mode musafir | Belum ada (ada `geolocator` dan `geocoding`) | Rencana di §2 |
| Tasbih, Asmaul Husna, hadis harian | Tidak ditemukan modulnya (dzikir hanya dari `zikir_data_*.json`) | Rencana di §3 |
| Zakat (mal, penghasilan, fitrah) | Belum ada | Rencana di §4 |
| Halal scanner | Belum ada | Rencana di §5 — **tidak ada data per produk (API maupun Satu Data); v1 hanya membuka sumber resmi** |
| Koreksi tajwid saat hafalan | Hafalan memakai `speech_to_text` locale `ar-SA`: hanya level kata | Rencana di §6 — **spike disetujui; bukan janji fitur** |

## Urutan dan waktu

Ramadan 1448 H diperkirakan mulai **sekitar awal Februari 2027** [perkiraan; tergantung sidang isbat], sekitar 3 bulan dari sekarang. Karena itu urutannya:

| Gelombang | Isi | Kenapa |
|---|---|---|
| 1 | Fase 0 (lintang tinggi, instan waktu) → widget → tracker/qadha | Fondasi yang dipakai fitur lain |
| 2 (sebelum Ramadan) | **Ramadan/khatam**, **zakat (fitrah + mal)**, **tasbih + Asmaul Husna + hadis harian** | Paling terasa manfaatnya saat Ramadan |
| 3 | Mode musafir | Butuh instan waktu dan tracker dari gelombang 1 |
| 4 | Halal scanner | Bergantung jawaban BPJPH |
| 5 | Koreksi tajwid | Butuh R&D; risiko tertinggi |

Ukuran: S = beberapa hari, M = 1–2 minggu, L = lebih dari itu. Perkiraan kasar, bukan komitmen.

---

## Bagian I — Gelombang 1: Lintang tinggi, Widget Android, Tracker Sholat, Qadha

### Temuan dari kode yang mengubah rencana

1. **Murajaah (Leitner) tampaknya sudah dibangun** — `muraja_ah_scheduler.dart`, wiring di `background_service.dart`, tabel `hafalan_sessions` (skema v14–16). Tidak masuk rencana ini. *(Sebelumnya saya menyebutnya "belum dibangun" — itu keliru.)*
2. **`PrayerRepositoryImpl.getPrayerTime` mengembalikan string `'HH:mm'`** yang diformat di zona waktu perangkat, bukan instan waktu. Widget dan tracker butuh **instan absolut (epoch ms)**; kalau tidak, kota lain zona/waktu musafir akan salah. → prasyarat (Fase 0).
3. **Tidak ada penanganan lintang tinggi.** `grep highLatitude` di `lib/` kosong. Dokumentasi `adhan` mencantumkan `HighLatitudeRule` (`middle_of_the_night`, `seventh_of_the_night`, `twilight_angle`) tetapi tidak menyebut nilai default → **perilaku default belum diverifikasi**; harus diuji dengan koordinat nyata (Fase 0).
4. **Hanya 2 metode hitung** (`singapore`, `kemenagRI`), keduanya diset `Madhab.shafi`.
5. **Job harian Workmanager** (`muslimly_daily_refresh`, ~03:00) punya constraint `NetworkType.connected` — di hari offline, semua isinya ikut terlewat. Data widget **tidak boleh** bergantung padanya saja.
6. **Notifikasi lokal sudah ada** (`schedulePrayerNotification`, channel adhan/beep/silent, izin `SCHEDULE_EXACT_ALARM` + boot receiver), tetapi **belum ada action button**; tap hanya navigasi lewat payload.
7. **DB sqflite versi 16** → fitur ini jadi v17. Tidak ada unit test berarti di repo; `sqflite_common_ffi` sudah ada di dev_dependencies, jadi test DB mungkin dilakukan.

---

### Fase 0 — Prasyarat (kecil, wajib sebelum yang lain)

1. **API instan waktu sholat.** Tambah method di domain `prayer`, mis. `getPrayerInstants(lat, lng, date) → PrayerInstants` (`DateTime` UTC untuk fajr/sunrise/dhuhr/asr/maghrib/isha). `getPrayerTime` lama (string) tetap, dibangun di atas ini supaya tidak ada dua sumber kebenaran.
2. **Lintang tinggi.**
   - Tambah setting `highLatitudeRule` (auto/tengah-malam/1-7/twilight) di `PrayerCalculationMethod`/settings.
   - Mode **auto**: di atas ±48° pakai aturan fallback (sumber: panduan `adhan`: 1/7 malam di atas 48°). Angka ambang final = keputusan produk.
   - Uji: Tromsø & Oslo (Juni), Jakarta (golden test vs data Kemenag untuk satu tanggal), satu lokasi mendekati kutub.
3. **Unit test** untuk 1 dan 2 (fungsi murni, tidak butuh device).

---

### A. Widget Android

**Prinsip:** widget tidak menjalankan Flutter. Flutter hanya menulis **data** ke SharedPreferences; widget native (Kotlin) membaca dan merender. Countdown dirender sistem lewat `Chronometer` (hitung mundur), jadi tidak perlu update tiap detik.

**Paket:** `home_widget` (belum ada di `pubspec.yaml`).

#### A1. Jembatan data — `WidgetDataService` (Dart)
- Tulis JSON: `{generatedAt, cityName, methodKey, days: [{date, prayers: [{key, startEpochMs, endEpochMs}]}]}` untuk **7 hari ke depan** (murah — hitung offline pakai `adhan`). 7 hari, bukan 24–48 jam, supaya widget tetap benar beberapa hari tanpa app dibuka atau job harian.
- Dipicu: app start/resume, ganti kota/lokasi/metode, job harian, dan setelah check-in tracker.
- **Jangan** bergantung pada constraint `NetworkType.connected` job harian. Karena murajaah sudah memakai job yang sama, pertimbangkan melonggarkan constraint itu (cek dampaknya pada notifikasi progres baca, yang tidak butuh jaringan juga).

#### A2. Widget native (Kotlin)
- `PrayerWidgetProvider` + layout RemoteViews. Dua ukuran:
  - **Kecil (2×1):** nama sholat berikutnya + `Chronometer` hitung mundur.
  - **Sedang (4×2):** 5 waktu hari ini, yang berikutnya disorot; (nanti) ceklis tracker.
- Provider menghitung "sholat berikutnya" **saat render** dari epoch di JSON — bukan dari state tersimpan.
- Tap → deep link ke halaman sholat (route sudah ada: `/dashboard?index=1`) atau tracker (setelah Fase 2).
- Manifest: tambah `<receiver>` provider + `appwidget-provider` XML.

#### A3. Pembaruan di batas waktu sholat
- Saat sholat berikutnya masuk, widget harus berpindah ke berikutnya. Dua jalur:
  1. **AlarmManager exact** per waktu sholat memicu update widget (izin `SCHEDULE_EXACT_ALARM` sudah dideklarasikan). Jadwal ulang di `BOOT_COMPLETED` (receiver boot sudah ada untuk notifikasi; widget perlu receiver sendiri).
  2. **Fallback bila izin exact alarm ditolak** (kasus umum di Android 14+ **[detail perilaku belum diverifikasi]**): update tidak presisi; widget bisa terlambat berpindah beberapa menit. Terima dan dokumentasikan — jangan pakai `setAlarmClock` (memunculkan ikon alarm di status bar).
- **Risiko OEM** (Xiaomi/Oppo/dll. yang mematikan proses): sama dengan masalah notifikasi adhan yang sudah ada; README sudah menyebut Battery Optimization. Tambahkan petunjuk di pengaturan.

#### Di luar lingkup v1
- Widget layar kunci Android, Wear OS, dan "notifikasi hitung mundur ongoing" (pengganti Live Activity). **[Ketersediaan widget layar kunci & perilaku ongoing notification Android 14+ belum diverifikasi]** — klaim saya sebelumnya soal "Android 16" ditarik.
- iOS WidgetKit + Live Activity: fase terpisah setelah ada device uji.

---

### B. Tracker Sholat

#### B1. Slot dan jendela waktu
Satu slot = `(slot_date, prayer)`. Jendela:

| Sholat | Mulai | Akhir |
|---|---|---|
| Subuh | fajr | sunrise |
| Dzuhur | dhuhr | asr |
| Ashar | asr | maghrib |
| Maghrib | maghrib | isha |
| Isya | isha | fajr berikutnya |

`slot_date` = tanggal lokal dari **awal** jendela (Isya setelah tengah malam tetap milik hari sebelumnya). Semua perhitungan jendela dari `PrayerInstants` (Fase 0), tidak dari string.

**Penyederhanaan dari penjelasan saya sebelumnya:** status "terlambat" di dalam jendela **dihapus** (definisinya subjektif). Cukup: dikerjakan **dalam jendela** = tepat waktu; **setelah jendela** = qadha. `jamaah` jadi flag boolean.

#### B2. Model data — satu tabel log append-only
Meniru `hafalan_sessions`: **satu log sebagai source of truth, semua rollup (streak, status slot, saldo qadha, statistik) adalah fungsi murni** — tidak ada counter/snapshot terpisah.

`prayer_logs` (SQLite v17):
`id, kind, prayer, slot_date, count, in_jamaah, timestamp, is_synced`

`kind`:
- `performed` — slot dikerjakan dalam jendela (`slot_date`, `prayer`, `in_jamaah`).
- `missed` — pengguna **mengonfirmasi** slot terlewat (menambah utang 1).
- `qadha_done` — mengganti utang (`prayer`, `count`, default 1).
- `qadha_baseline` — hasil wizard / penyesuaian manual, `count` bertanda (boleh negatif).

Aturan fold: untuk `performed`/`missed` pada slot yang sama, **entri dengan `timestamp` terbaru menang** (koreksi pengguna).
Saldo qadha per sholat = Σ`qadha_baseline` + #`missed` − Σ`qadha_done`, ditampilkan minimal 0.

#### B3. File Flutter (fitur baru `features/prayer_tracker/`, struktur data/domain/presentation seperti fitur lain)
- `domain/entities/prayer_log.dart`, `prayer_slot.dart`
- `domain/utils/prayer_slot_resolver.dart` — jendela & status slot (fungsi murni)
- `domain/utils/prayer_tracker_calculator.dart` — streak, statistik, saldo qadha (fungsi murni)
- `data/` — repository + method di `database_service.dart` (`insertPrayerLog`, `getPrayerLogs({since})`, `getUnsyncedPrayerLogs`, `markPrayerLogsSynced`, `mergeRemotePrayerLogs`); naikkan versi DB ke 17 + `onUpgrade` (`if (oldVersion < 17)`) **dan** `onCreate`.
- `presentation/bloc/prayer_tracker_cubit.dart`, `pages/prayer_tracker_page.dart`, kartu dashboard (di samping `dashboard_daily_goal_card_widget.dart`), route baru di `app_router.dart`.
- DI: registrasi di `di_container.dart` (urutan: setelah fitur Prayer).
- l10n: tambah kunci di `app_en.arb` dan `app_id.arb`.

#### B4. Check-in dan nudge
- **Check-in:** tombol di kartu dashboard, di widget (nanti), dan **action button notifikasi** ("Sudah sholat").
- **Action button di background:** butuh handler top-level `@pragma('vm:entry-point')` untuk respons notifikasi di background isolate, yang menulis ke SQLite. Risiko: koneksi DB kedua dari isolate lain **[belum diverifikasi aman dengan singleton `DatabaseService` saat ini]**. Opsi aman v1: action hanya membuka app ke halaman check-in.
- **Nudge lembut:** notifikasi terjadwal tiap slot (mis. 20–30 menit sebelum jendela berakhir, default bisa diatur), **dibatalkan saat slot dicek-in** atau saat uzur dimulai. Nada netral, bukan menuduh. Pakai channel baru; ID tidak boleh bentrok dengan `kMurajaahNotificationId` dan ID adzan yang ada.
- **Penutupan slot:** setelah jendela berakhir tanpa log → status "belum dicatat". Pengguna memilih: *sudah sholat* (log `performed`, tanpa klaim tepat waktu) atau *terlewat* (log `missed` → utang). Tidak pernah otomatis jadi utang.

---

### C. Qadha + Wizard Perkiraan Utang

#### C1. Daftar qadha
- Saldo per sholat (Subuh…Isya) + total; tombol "Ganti 1" (`qadha_done`); undo.
- Target pace opsional: "ganti N per hari" + perkiraan tanggal lunas; pengingat lokal opsional (mis. setelah tiap fardhu).

#### C2. Wizard (`qadha_wizard_page.dart`, logika di `qadha_estimator.dart` — fungsi murni, mudah diuji)
Langkah:
1. **Rentang:** sejak kapan baligh (tanggal/usia) → mulai rutin sholat.
2. **Pola:** (a) *tidak pernah sholat* → hari × 5; (b) *kadang* → estimasi per sholat per minggu; (c) *isi manual per sholat*.
3. **Koreksi uzur (opsional, ditanya netral):** perkiraan hari haid/nifas per bulan/periode yang dikurangi.
4. **Tinjau:** hasil per sholat bisa diedit → disimpan sebagai `qadha_baseline` (bisa dijalankan ulang; hasil baru jadi entri penyesuaian, bukan menimpa).

**Catatan fiqh & tone:** aturan qadha dan cara menghitungnya berbeda antar mazhab. App menyajikan ini sebagai **alat pencatatan dan perkiraan**, bukan fatwa; tampilkan catatan singkat dan sarankan merujuk ustadz. Bahasa mendukung, tidak menghakimi.

---

### D. Uzur (Haid/Nifas/Sakit) — Lokal, Tetap Bisa Mengingatkan

- Tabel **terpisah & lokal-only** `prayer_excused_periods` (`id, kind, start_date, end_date nullable`). **Tidak** ikut `is_synced`, **tidak** dikirim ke backend, **tidak** dikirim ke analytics/Crashlytics (periksa `AppLogger` agar tidak mencatatnya).
- Slot yang jatuh dalam periode uzur diproyeksikan sebagai **"uzur"** saat dibaca (fungsi murni) — tidak ada baris `prayer_logs` bertipe uzur, sehingga **log yang ter-sync tidak membocorkan** status uzur.
- **Pengingat (tetap lokal, tidak butuh server):**
  1. Saat periode dimulai: tunda/batalkan nudge tracker dan murajaah selama periode.
  2. Pengingat **akhir periode** (pada tanggal perkiraan yang dipilih pengguna): "Sudah suci? Lanjutkan pencatatan."
  3. Opsional: pengingat **qadha puasa** setelah Ramadan bila ada hari uzur selama Ramadan.
- **Konsekuensi desain:** pengingat pintar berbasis server (`smart_notif_strategy.md`, FCM cron) **tidak boleh** dipakai untuk tracker sholat — server tidak tahu status uzur dan akan mengirim pengingat yang tidak pantas. Semua pengingat tracker = lokal.
- **Konsekuensi lintas-perangkat:** karena uzur lokal, perangkat kedua tidak tahu periode itu dan akan menampilkan slot "belum dicatat". Diterima untuk v1 (didokumentasikan di UI: "data ini hanya ada di perangkat ini").

---

### E. Sinkronisasi (backend `muslimly-be`) — fase terakhir

Meniru `hafalan_sessions` persis:
- `internal/features/sync/model/prayer_log.go`; DTO/service/repository/handler; route `POST|GET /sync/prayer-logs` di grup `sync` yang sudah ada (identitas ganda `user_id`/`device_id` via `resolveIdentity()`).
- Daftarkan `&syncModel.PrayerLog{}` di `AutoMigrate` pada `cmd/api/main.go`.
- **Migrasi baru dengan unique index dedup sejak awal** (jangan hanya `OnConflict DoNothing` — bug nyata di `reading_activities`). File migrasi **wajib** ditambahkan ke slice `order` di `migrations/migrations.go`, atau `TestOrderCoversAllFiles` gagal. Contoh sudah ada: `add_hafalan_session_dedup_index.sql`.
- Tambah pass `prayer_logs` di `MigrateGuestData` + counter baru di `dto.MigrateGuestResponse` dan handler `MigrateGuest`.
- **Tidak ada test DB nyata di CI** → kebenaran index/`ON CONFLICT` tidak akan tertangkap test. Verifikasi manual di staging.
- Rate limiter grup `/sync` dipakai bersama; kirim log berbatch.
- **Hanya `prayer_logs` yang di-sync.** Tabel uzur tidak.

---

### Urutan kerja yang disarankan

| # | Fase | Isi | Ukuran |
|---|---|---|---|
| 0 | Prasyarat | Instan waktu, lintang tinggi, unit test | S |
| 1 | Widget Android (countdown) | A1–A3, ukuran kecil + sedang tanpa ceklis | M |
| 2 | Tracker inti | B1–B4 tanpa sync | M |
| 3 | Qadha + wizard | C1–C2 | M |
| 4 | Uzur lokal + pengingat | D | S–M |
| 5 | Sync | E | M |
| 6 | Widget + ceklis tracker | integrasi A ↔ B | S |

### Status implementasi Gelombang 1 (2026-11-10)

| Fase | Status |
|---|---|
| 0–5 | Selesai dikode (instan waktu + lintang tinggi, widget Android, tracker, qadha + wizard, uzur lokal, sync backend + aplikasi) |
| 6 | **Selesai dikode.** Widget ukuran sedang menampilkan tanda ✓ (hijau) pada sholat yang sudah dicek-in; ketuk widget sedang membuka halaman tracker, widget kecil tetap membuka tab sholat. |

**Tambahan setelah uji emulator (2026-11-10):**
- Widget didesain ulang (gradien zamrud, aksen emas, pil hitung mundur) dan kini **tiga pilihan ukuran** di daftar widget: *Kecil* 2×1 (sholat berikutnya + hitung mundur), *Strip* 4×1 (hitung mundur + kelima waktu sebaris), *Daftar* 4×3 (satu baris per sholat). Varian = kelas provider (`PrayerWidgetProvider`, `PrayerWidgetStripProvider`, `PrayerWidgetListProvider`); Strip dan Daftar membuka tracker saat diketuk, Kecil membuka tab sholat.
- Bug ditemukan & diperbaiki: ketuk widget saat app sudah berjalan tidak menavigasi (stream `home_widget` tidak terpicu). Solusi: `MainActivity` (turunan `AudioServiceActivity`) meneruskan deep link lewat MethodChannel `com.muslimly.app/widget_launch`; `go()` lalu `push()` berurutan juga menjatuhkan push, kini tracker hanya di-`push`.
- Terverifikasi di emulator (Pixel Tablet dengan ukuran layar HP 1080x2400): check-in → ✓ muncul di widget; cold start dan warm start → halaman tracker; varian Kecil dan Strip tampil benar.
- **Belum terverifikasi visual:** varian Daftar dengan desain baru (hanya preview picker); perilaku di perangkat fisik/OEM lain.
- Halaman tracker dirapikan: hari-hari sebelumnya yang belum dicatat diringkas jadi satu kartu per hari (hari terbaru terbuka, lainnya terlipat) dengan chip lima sholat, bottom sheet untuk mencatat satu sholat, dan aksi "Tandai semua sudah sholat" dengan dialog konfirmasi (`PrayerTrackerCubit.checkInMany`; tidak pernah jadi utang otomatis). Tanggal ditampilkan ramah ("Kemarin · Sen, 9 Nov").
- Sync log gagal di emulator (`Prayer log sync failed`) karena belum login/staging belum menerima — perlu dicek saat uji staging.

**Keputusan Fase 6:** ceklis **tidak** menulis dari widget. Sesuai catatan B4 (koneksi DB kedua dari isolate lain belum terverifikasi aman), check-in tetap dilakukan di app; widget hanya *menampilkan* status. Widget hanya menerima flag `done` (sudah sholat) — status *missed*/*uzur* sengaja **tidak** ditulis ke layar utama (privasi). Widget diperbarui setelah check-in/markMissed dan setelah sync yang menggabungkan baris baru (`PrayerTrackerCubit.onLogsChanged` → `WidgetDataService.updateFromStoredLocation`).

**Belum dikerjakan:**
- ~~`swag init`~~ sudah dijalankan (docs/ diperbarui, ikut memuat rute hafalan yang sebelumnya belum terdokumentasi); deploy dan cek staging (index unik `prayer_logs`, `ON CONFLICT`)
- Uji perangkat: widget (pergantian di batas waktu, ✓ setelah check-in, ketuk → tracker), nudge, sync dua perangkat
- Tinjauan ustadz: wizard qadha, perlakuan sakit, rumus estimasi
- Keputusan terbuka: ambang lintang 48 vs 55; default nudge (kini aktif, 30 menit); constraint jaringan job harian
- Perubahan backend `muslimly-be` belum di-commit

Fase 1 dan 2 independen dan bisa dikerjakan paralel setelah Fase 0.


---

## Bagian II — Gelombang 2–5: Fitur lain

### 1. Perencana Ramadan & Khatam — ukuran M

**Tujuan:** pengguna memilih target khatam dan tanggalnya; app menghitung target harian dan menyesuaikannya saat tertinggal.

**Yang sudah ada:** target baca harian (`getDailyReadingTarget`/`getDailyAyahTarget`), statistik baca (`ReadingBloc`), kartu target di dashboard, tabel `reading_activity`, paket `hijri`, dan konfigurasi koreksi Hijriah dari backend.

**Rancangan:**
- Input: tanggal mulai, tanggal target (preset "khatam di Ramadan" memakai tanggal Hijriah), jumlah khatam (1× atau lebih), hari libur baca (opsional).
- Perhitungan (fungsi murni, mudah diuji): `sisa halaman / sisa hari`. Mushaf punya 604 halaman, jadi 1× khatam dalam 30 hari ≈ 20,1 halaman/hari, atau sekitar 4 halaman per waktu sholat.
- Sumber kebenaran: **progres diturunkan dari log `reading_activity`**, bukan counter terpisah (pola yang sama dengan fitur lain). Satu tabel kecil lokal `reading_plans` (tanggal mulai, target, jumlah khatam, hari libur).
- Penyesuaian otomatis: tiap hari hitung ulang target dari sisa; tampilkan "kejar X halaman" tanpa nada menghakimi.
- **Keputusan produk:** "halaman yang dihitung" = jumlah halaman dibaca, atau halaman unik sejak rencana dimulai? Khatam berarti membaca seluruh 604 halaman, jadi halaman unik lebih tepat. Perlu dicek bagaimana `reading_activity` mencatat halaman yang diulang.
- Awal Ramadan bisa berbeda satu hari; beri penyesuaian ±1 hari oleh pengguna.

**Risiko / jebakan:**
- `smart_notif_strategy.md` memakai `target_value` yang di-sync ke server untuk mengirim pengingat. Jika rencana mengubah target harian tiap hari, nilai itu harus ikut di-sync, kalau tidak pengingat server akan salah.
- Hari haid: sebagian pengguna tetap membaca dan sebagian tidak, tergantung pendapat. Jangan mengasumsikan; cukup sediakan "hari libur baca" yang dipilih pengguna. Jangan ambil dari data uzur lokal di tracker tanpa persetujuan.

---

### 2. Mode Musafir — ukuran L

**Tujuan:** membantu pengguna yang bepergian: zona waktu, waktu sholat di lokasi baru, dan saran qasr/jamak.

**Bergantung pada:** Fase 0 (waktu sholat sebagai instan absolut) dan tracker.

**Rancangan:**
- **Deteksi:** bukan pelacakan latar belakang. Saat app dibuka (atau waktu sholat dihitung ulang), bandingkan lokasi sekarang dengan "kota asal". Jika jauh, tanyakan: "Apakah Anda sedang safar?" Pengguna yang memutuskan.
- **Hindari izin lokasi latar belakang:** `ACCESS_BACKGROUND_LOCATION` memicu kebijakan Play Store yang ketat dan terasa mengganggu bagi pengguna. Manifest sekarang hanya punya lokasi foreground.
- **Perencana perjalanan opsional:** pilih kota tujuan (pakai `geocoding` yang sudah ada) → jarak → apakah memenuhi ambang safar untuk mazhab pilihan pengguna.
- **Ambang jarak berbeda antar mazhab** (riset sebelumnya: sekitar 21 km di sumber Hanafi; angka lain dari mazhab lain). Jadikan setelan per mazhab; angka final **[perlu ditinjau ustadz/pakar fiqh]**.
- **Saran qasr/jamak:** disajikan sebagai informasi, bukan fatwa. Qasr dan jamak adalah dua hal berbeda; jamak tidak otomatis berlaku sepanjang perjalanan. Sertakan aturan lama tinggal menurut mazhab.
- **Zona waktu:** pakai instan absolut; hitung ulang jadwal dan jadwalkan ulang notifikasi saat zona waktu perangkat berubah dan saat boot. Jadwal notifikasi sekarang memakai `tz.local`, jadi perilaku saat perangkat pindah zona perlu diuji **[belum diverifikasi]**.
- **Tracker:** tambah flag `qasr` dan `jamak` (taqdim/ta'khir) di `prayer_logs`.

**Risiko:** fiqh safar kompleks dan sensitif. Fitur ini paling aman sebagai alat bantu yang transparan tentang asumsinya.

---

### 3. Tasbih, Asmaul Husna, Hadis Harian — ukuran S–M

Fitur konten dan alat ringan, risiko teknis rendah. Cocok dikerjakan sebelum Ramadan.

**Tasbih:**
- Penghitung dengan target (33/99/kustom), getaran, undo, riwayat sesi, tersimpan lokal. Getaran bawaan Flutter (`HapticFeedback`) cukup; paket `vibration` hanya bila butuh pola khusus **[belum dievaluasi]**.
- Tempatkan di fitur Dzikir. Opsional nanti: tombol cepat di widget.
- Layar tetap menyala selama sesi (perlu paket/izin kecil; evaluasi).

**Asmaul Husna:** 99 nama, JSON offline dengan Arab, transliterasi, dan arti ID/EN, mengikuti pola `zikir_data_*.json`. **Teks dan arti harus ditinjau**, bukan disalin mentah dari satu situs.

**Hadis harian:**
- Ada dataset sumber terbuka dengan terjemahan Indonesia, mis. `gadingnst/hadith-api` (lisensi MIT menurut listing), tetapi **lisensi dan asal terjemahan harus dicek di repositori masing-masing**. Hak cipta terjemahan bisa berbeda dari lisensi kode.
- Saran cakupan v1: koleksi kecil dan terkurasi (mis. Arba'in Nawawi dan pilihan Bukhari/Muslim), dibundel offline dalam JSON, **bukan** memanggil API pihak ketiga saat runtime.
- Sertakan rujukan (kitab, nomor), dan peninjauan oleh orang yang paham. Jangan klaim "sahih" kecuali dari sumber yang menyatakannya.
- Hadis harian menyambung ke `daily_inspiration_page.dart` yang sudah ada.

---

### 4. Zakat — ukuran M–L

**Tujuan:** kalkulator mal, penghasilan, fitrah dengan nisab otomatis, riwayat, dan pengingat haul.

**Temuan riset (2026-11-10) — angka resmi sudah ada, API harga emas tidak wajib:**
- **Nisab zakat penghasilan & jasa 2026 ditetapkan BAZNAS** lewat SK Ketua BAZNAS No. 15/2026, berlaku sejak 21 Februari 2026 (menggantikan SK No. 13/2025): **Rp91.681.728 per tahun atau Rp7.640.144 per bulan**, kadar 2,5% dari penghasilan bruto. Sumber: [Warta Ekonomi](https://wartaekonomi.co.id/read602278/baznas-tetapkan-nisab-zakat-2026-naik-7-sesuai-kenaikan-upah-nasional-gaji-764-juta-wajib-zakat), [Metro TV](https://www.metrotvnews.com/read/N4ECo24o-baznas-tetapkan-wajib-zakat-masyarakat-berpenghasilan-rp7640144-per-bulan).
- **Catatan penting:** nilai BAZNAS itu berbasis 85 gram emas, tetapi memakai **acuan emas 14 karat**, bukan 24 karat. Ada kritik akademik atas pendekatan ini; BAZNAS merujuk kaidah mazhab Hanafi. **Keputusan Anda: standar bawaan = emas 24 karat; nisab penghasilan versi BAZNAS ditunda** sampai konsultasi ustadz. Rancang kodenya agar standar nisab berupa konfigurasi (bisa ditambah nanti tanpa menulis ulang perhitungan).
- **Zakat fitrah 2026:** satu artikel menyebut SK Ketua BAZNAS No. 14/2026: **2,5 kg beras (≈3,5 liter) atau Rp50.000 per jiwa**, dan nilai rupiah itu untuk Jakarta dan sekitarnya; daerah lain bisa berbeda ([sumber](https://www.goodnewsfromindonesia.id/2026/02/27/berapa-zakat-fitrah-2026-ini-ketetapan-resmi-baznas-terbaru)). **[Tanggal SK dan nilai per daerah belum terverifikasi dari dokumen resmi BAZNAS.]**
- **API harga emas (hanya bila ingin nisab 24 karat):**
  - Tidak ada API resmi Antam/Logam Mulia yang saya temukan. `ferryops/logam-mulia` tidak resmi dan datanya dari 2025.
  - GoldAPI.io memakai endpoint `/api/XAU/{currency}`; batas paket gratis dilaporkan berbeda antar sumber (500 vs 1000 permintaan/bulan) dan **dukungan IDR belum diverifikasi**.
  - API Ninjas melarang penggunaan komersial di paket gratis. Metals-API: batas gratis dilaporkan 50 permintaan/bulan.
  - Harga yang dikembalikan API semacam ini adalah **harga spot dunia (per troy ounce, 31,1035 g)**, bukan harga eceran Antam; hasilnya akan berbeda.
- **Keputusan Anda: harga emas diperbarui otomatis, mingguan.** Perancangannya di bawah ("Harga emas otomatis").
- **Logam Mulia/Antam tidak bisa dijadikan sumber otomatis.** Saat saya mencoba mengaksesnya dari skrip (`logammulia.com`, termasuk `robots.txt`), server menjawab **403 Access Denied** — situs itu memblokir akses otomatis, dan tidak ada API resmi atau syarat penggunaan data yang bisa saya temukan. Saya **tidak** akan mencoba menembus pemblokiran itu, dan saya tidak menyarankan scraping.
- Nisab dihitung di app: **85 gram × harga emas 24 karat per gram**.

**Harga emas otomatis (rancangan backend):**
- **Sumber: API harga emas spot (XAU) ke IDR dari penyedia berbayar-kecil/gratis**, dikonversi ke per gram (1 troy ounce = 31,1035 g). Emas spot 99,99% setara 24 karat. Mingguan hanya ±5 panggilan/bulan, jauh di bawah batas paket gratis yang dilaporkan (sekitar 100/bulan di beberapa penyedia).
- **Yang belum terverifikasi dan harus dicek sebelum membangun:** (a) penyedia mana yang benar-benar mendukung **XAU→IDR** pada paket gratis (halaman harga yang saya baca tidak menyebut IDR secara eksplisit), dan (b) **syarat penggunaan** untuk menampilkan datanya di aplikasi publik (beberapa penyedia melarang penggunaan komersial di paket gratis). Cara termurah: daftar satu kunci API gratis dan panggil sekali — itu **langkah Anda**, saya tidak bisa membuat akun/kunci.
- **Penyedia dibuat bisa diganti** (antarmuka kecil di Go): bila satu penyedia berubah syarat atau mati, ganti tanpa mengubah app.
- **Penjadwalan:** `robfig/cron` sudah dipakai di `cmd/api/main.go` (zona waktu Asia/Jakarta). Tambah satu job mingguan (mis. Senin pagi).
- **Penyimpanan:** tabel `gold_prices` (tanggal, harga per gram IDR, sumber, jenis `spot`/`manual`), bukan hanya satu nilai terakhir. Riwayat ini berguna untuk **nisab pada tanggal haul**. Tampil di app lewat `app_config` (`price_per_gram_idr`, `as_of`, `source`, `kind`, `nisab_gram: 85`).
- **Pengaman:** (1) bila panggilan gagal, pertahankan nilai lama dan tandai usang setelah >14 hari di app; (2) bila harga berubah >15% dari minggu lalu, **jangan terbit otomatis** — tahan dan beri tahu admin (ambang 15% adalah usulan saya); (3) **timpaan manual admin selalu menang**; (4) pengguna tetap bisa menimpa dengan input manual di app.
- **Transparansi di app (wajib):** tampilkan "Harga emas spot dunia per tanggal X, sumber Y — **bukan harga eceran Antam**". Selisih keduanya ada; besarnya tidak saya ukur. Harga spot yang lebih rendah menurunkan nisab, sehingga lebih banyak orang melewatinya; **mohon ditanyakan ke ustadz** apakah acuan spot dapat diterima atau harus harga eceran emas batangan.
- **Tarif fitrah** (dan, bila nanti diaktifkan, nisab BAZNAS) disimpan di `app_config` **bersama nomor SK, tanggal berlaku, dan sumber**, diperbarui admin tahunan.

**Rancangan:**
- Jenis: zakat mal (harta ≥ nisab dan sudah haul 1 tahun), fitrah, dan penghasilan.
- **Zakat penghasilan: ditunda.** Sampai ada keputusan ustadz, perhitungan memakai nisab emas 24 karat dengan haul 1 tahun, yaitu penghasilan/harta terkumpul selama setahun dibandingkan nisab (tafsiran ini **sudah dikonfirmasi Anda**, 2026-11-10).
- Tarif 2,5%. **Tinjauan ustadz diperlukan** sebelum rilis.
- Fitrah: nilai diambil dari konfigurasi resmi, tidak di-hardcode di app.
- Riwayat perhitungan tersimpan lokal; pengingat haul pakai tanggal Hijriah (`hijri` + koreksi dari backend).
- Penyaluran: tautan ke lembaga resmi (BAZNAS dll.), **tanpa memproses pembayaran sendiri** di v1.

**Privasi:** data keuangan sensitif. Simpan lokal, jangan masukkan ke analytics/Crashlytics, dan jelaskan di kebijakan privasi.

---

### 5. Halal Scanner — ukuran M, **ditahan**

**Temuan riset mendalam (2026-11-10):**
- **Tidak ada API publik resmi yang terdokumentasi** untuk data sertifikat/produk halal BPJPH. Yang ada: pencarian web di [bpjph.halal.go.id](https://bpjph.halal.go.id/detail/cek-status-sertifikasi-halal-produk-di-halal-go-id-ini-caranya/) (nama produk, nama pelaku usaha, atau nomor sertifikat) dan QR pada label halal.
- **Portal [Satu Data BPJPH](https://satudata.halal.go.id/) sudah saya telusuri (2026-11-10): isinya hanya statistik agregat, tidak ada data per produk atau per sertifikat.** Portal ini aplikasi web yang membaca katalognya dari API publik miliknya sendiri; saya hanya memanggil daftar topik dan daftar dataset (baca saja). Hasilnya 12 topik dan sekitar 100 dataset, semuanya berupa jumlah, persentase, atau indeks: mis. *Jumlah Sertifikat Halal 2019–Mei 2026*, *Jumlah Produk Bersertifikat Halal*, *Jumlah Pelaku Usaha Bersertifikat Halal*, jumlah LPH/auditor/penyelia, pengawasan, dan indikator kinerja ASN/anggaran. **Tidak ada dataset daftar produk/sertifikat yang bisa dipakai pemindai.** Metadata dataset punya penanda format unduhan (CSV/JSON/XLS), tetapi **syarat penggunaan/lisensinya tidak tercantum** di sana. Endpoint katalog itu tidak terdokumentasi untuk pihak ketiga dan tidak perlu dipakai app.
- Hasil pertemuan BPOM–BPJPH (Maret 2026): pertukaran data **berbasis API antar-instansi** belum berjalan optimal dan BPJPH akan menyiapkan endpoint API terbaru ([BPOM](https://pusdatin.pom.go.id/berita/bpom-bpjph-integrasi-data-halal)). Itu untuk antar-instansi, bukan bukti ada API untuk publik.
- **Jalur tidak resmi ada:** proyek seperti [Verif-Halal](https://github.com/Jissena/Verif-Halal) dan aktor [Apify](https://apify.com/bareezh_codes/bpjph-halal-certificate-scraper) mengurai HTML `bpjph.halal.go.id/cari/sertifikat`. Keduanya menyatakan itu **bukan API resmi dan bisa putus** bila tampilan situs berubah; pencarian per nama produk juga tidak difilter server (hanya sebagian data terbaca). Saya **tidak menganjurkan** ini sebagai fondasi.
- Kontak BPJPH yang tercantum di salah satu hasil pencarian: layanan@halal.go.id **[belum saya verifikasi di situs resmi]**.

**Rekomendasi bertahap:**
1. **Satu Data BPJPH sudah dicek dan tidak cocok** (lihat di atas). Jalur yang tersisa untuk data per produk: **pertanyaan resmi ke BPJPH** soal akses data dan izin penggunaan. Itu opsional dan tidak memblokir v1.
2. **Jangan scraping** sebagai fondasi: rawan putus, ketentuan penggunaan tidak jelas, dan halal adalah keputusan sensitif.
3. **v1 tanpa data BPJPH:** pemindai QR/nomor sertifikat yang **membuka halaman verifikasi resmi** (`url_launcher` sudah ada). App tidak menyatakan halal atau tidaknya.
4. Pencarian bahan dari barcode itu masalah terpisah (basis data bahan tidak sama dengan status halal); jangan dijanjikan sebelum sumber datanya jelas.

---

### 6. Koreksi Tajwid saat Hafalan — **spike R&D**, ukuran L+

**Apa itu spike:** percobaan teknis singkat dengan batas waktu, tujuannya **menjawab satu pertanyaan** ("apakah ini cukup akurat untuk dijadikan fitur?") sebelum menginvestasikan waktu membangun fiturnya. Hasilnya keputusan lanjut/berhenti, bukan fitur jadi, dan kodenya dibuang atau dijadikan prototipe.

**Keadaan sekarang:** Hafalan memakai speech-to-text bawaan perangkat (`ar-SA`) dan mencocokkan per kata. Itu tidak bisa menilai tajwid (panjang mad, ghunnah, makhraj).

**Temuan riset (2025):**
- Ada riset dan rilis terbuka tentang deteksi kesalahan pengucapan Al-Quran: model wav2vec2/HuBERT, dataset dan model dari Abdelfattah dkk. (arXiv:2509.00094, klaim PER 0,16% pada set uji mereka), benchmark QuranMB (galat terendah yang dilaporkan 16,42%), dan sistem peserta Iqra'Eval 2025.
- Selisih besar antara klaim pada set uji sendiri dan benchmark independen menunjukkan **akurasi di dunia nyata belum terbukti** untuk produk. Lisensi kode, data, dan model **belum saya cek**.
- Tarteel sendiri (blog resmi) menyebut level huruf (harakat, pelafalan, tajwid) belum didukung.

**Status: spike disetujui (2026-11-10).** Dijadwalkan setelah Gelombang 1–2 (tidak memblokir rilis sebelum Ramadan).

**Rencana:**
1. **Spike terbatas waktu** (mis. 2 minggu): kumpulkan 50–100 rekaman uji dengan label ahli, coba model terbuka offline, ukur akurasi sebenarnya terhadap rekaman Anda (suara anak, dewasa, perangkat murah). **Pelabelan memerlukan guru tajwid/qari**, bukan hanya developer. Cek dulu lisensi kode, data, dan model yang akan dipakai.
2. **Gerbang keputusan** (ditetapkan **sebelum** spike mulai, bukan sesudah melihat hasil): lanjut hanya jika presisi per jenis kesalahan melewati ambang yang Anda tetapkan bersama guru tajwid. Salah menyatakan bacaan benar atau salah merugikan kepercayaan.
3. Jika lanjut: inferensi di server atau di perangkat? Perangkat lebih ramah privasi tetapi berat; server butuh infrastruktur (VPS Anda 1 GB RAM tidak cukup untuk model ini **[perkiraan]**). Rekaman suara anak: tetap **opt-in** seperti rencana Hafalan §F.
4. **Alternatif berisiko rendah** yang bisa dikerjakan tanpa spike: tampilkan **hukum tajwid pada ayat** (parser dan legenda sudah ada) sebagai bantuan belajar, tanpa menilai bacaan pengguna.

---

## Keputusan yang masih terbuka

**Untuk Anda dan ustadz (konten):**
1. **Zakat penghasilan versi BAZNAS:** ditunda (sementara emas 24 karat, haul 1 tahun).
2. Tinjauan zakat (mal, fitrah), safar (ambang jarak per mazhab, qasr/jamak), Asmaul Husna, dan hadis. Wording wizard qadha dan disclaimer fiqh-nya juga.
2a. **Acuan harga emas:** apakah harga **spot dunia** (satu-satunya yang bisa diotomatisasi) dapat diterima untuk nisab, atau harus harga eceran emas batangan (Antam)? Jika harus Antam, otomatisasi tidak mungkin dan kembali ke input manual oleh admin.

**Untuk Anda (produk dan teknis):**
3. **Kunci API harga emas:** daftar satu kunci gratis di penyedia kandidat, panggil `XAU→IDR` sekali, dan periksa (a) IDR didukung di paket gratis, (b) syarat penggunaan untuk aplikasi publik. Hasilnya menentukan penyedia pertama.
4. **Backend:** setuju tabel `gold_prices` + job mingguan + ambang tahan otomatis 15% (§4)? Tarif fitrah tetap diperbarui admin tahunan di `app_config`.
5. **BPJPH:** apakah tetap mau mengirim pertanyaan akses data per produk? (Opsional; tidak memblokir v1.)
6. **Lintang tinggi:** ambang mode otomatis (48° atau 55°) dan aturan default.
7. **Subuh berakhir di sunrise** — setuju? (default paling umum; ada pendapat lain).
8. **Nudge tracker:** waktu default (20 atau 30 menit sebelum jendela berakhir) dan aktif atau tidak secara default.
9. **Constraint jaringan job harian:** boleh dilonggarkan? Berdampak pada notifikasi yang sudah ada.

