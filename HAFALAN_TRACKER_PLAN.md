# Hafalan Tracker — Rencana Implementasi

> Draft untuk direview. Belum ada kode yang diubah — dokumen ini murni rencana.
>
> **Update (2026-09-12):** ronde riset kedua — verifikasi ulang semua klaim teknis di dokumen ini terhadap kode aktual (`muslimly` + `muslimly-be`), plus riset UX khusus untuk D (Mode Anak) dan E (Gamifikasi) supaya benar-benar ramah-anak, bukan cuma "streak dewasa yang dikecilkan". Temuan digabung inline di tiap seksi di bawah, ditandai **[Riset #2]**.

---

## Latar Belakang

Fitur `Hafalan` saat ini (`lib/src/features/quran/presentation/bloc/hafalan/hafalan_bloc.dart`) sudah punya mekanisme pengecekan bacaan real-time berbasis speech-to-text (pencocokan kata per kata, reveal hijau/merah, skor akurasi per ayat) — tapi **sepenuhnya ephemeral**: `HafalanBloc` baru dibuat setiap buka halaman dan di-reset tiap ganti halaman mushaf (`hafalan_page.dart:274`). Tidak ada yang tersimpan lintas sesi, tidak ada target per-surah/juz, tidak ada penjadwalan muraja'ah, tidak ada mode ramah-anak, dan tidak ada gamifikasi.

Tujuannya: mengubah ini jadi tracker hafalan sungguhan yang bisa dipakai anak-anak maupun dewasa — mengejar apa yang jadi nilai jual utama di app kompetitor (Tarteel AI) dan metode tahfizh tradisional (ziyadah + muraja'ah, talaqqi): progress jangka panjang, review terjadwal, dan motivasi — bukan cuma mekanisme reveal-nya, yang sudah dimiliki Muslimly.

Rencana ini dipecah jadi 6 sub-fitur (A tidak bergantung apa pun; B, C, E, F bergantung pada A; D independen tapi menyentuh skema A).

**Keputusan yang sudah diambil:**
- Sesi yang direkam di mode anak/lembut dihitung sebagai progress resmi (satu jalur data yang sama dengan mode ketat, tidak perlu flag `kidsMode` di skema) — model data lebih sederhana, dan latihan anak tetap dihitung sebagai progress nyata, bukan hilang begitu saja dari statistiknya sendiri.
- Rekaman audio (F) **opt-in, default OFF** — karena berpotensi merekam suara anak, tidak boleh nyala diam-diam.
- Retensi rekaman: **hanya rekaman terbaru per (surah, halaman) yang disimpan otomatis**, rekaman lama di unit yang sama ditimpa — kecuali user menekan "simpan"/bintang pada rekaman tertentu, yang membuatnya kebal dari auto-hapus.

## Prinsip Arsitektur yang Dipakai di Semua Sub-Fitur

Codebase ini sudah punya idiom untuk statistik (terlihat di `ReadingBloc._calculateLifetimeStats`, `reading_bloc.dart` ~183-263): simpan **satu log append-only sebagai source of truth**, turunkan semua rollup (streak, status per-unit, milestone) sebagai **fungsi murni** yang dihitung ulang dari log itu — bukan menyimpan counter/snapshot terpisah yang bisa jadi tidak sinkron. Semua sub-fitur di bawah mengikuti pola ini — hanya ada **satu tabel baru** (`hafalan_sessions`); sisanya proyeksi dari situ.

---

## A. Persistensi Progress Hafalan (Fondasi)

Meniru pola `reading_activity` persis (`internal/features/sync/model/reading_activity.go`, `quran_repository_impl.dart:211-244` `syncUnsyncedActivities`, kolom `is_synced` di `database_service.dart`).

**Unit satu sesi:** satu baris per **penyelesaian satu halaman mushaf** (`HafalanStatus.completed` di `hafalan_bloc.dart`) — sesuai granularitas reveal yang sudah ada, tidak perlu semantik completion baru.

**Flutter:**
- `lib/src/features/quran/domain/entities/hafalan_session.dart` — field: `id, surahNumber, pageNumber, startAyah, endAyah, ayahCount, accuracy (dari state.overallAccuracy), date (YYYY-MM-DD), timestamp, isSynced`.
- `database_service.dart` — tabel baru `hafalan_sessions`, naikkan versi skema (cek versi terkini dulu — saat ini 14), tambah `insertHafalanSession`, `getUnsyncedHafalanSessions`, `markHafalanSessionsSynced`, `mergeRemoteHafalanSessions`, `getHafalanSessions({surahNumber?, since?})`.
- `quran_repository_impl.dart` — `syncUnsyncedHafalanSessions`, meniru `syncUnsyncedActivities`.
- `sync_api_service.dart` — `bulkInsertHafalanSessions`.
- `hafalan_page.dart` — tambah `BlocListener<HafalanBloc, HafalanState>` di sekitar `PageView` (saat ini belum ada, cuma `BlocBuilder`) dengan `listenWhen: (prev, curr) => prev.status != HafalanStatus.completed && curr.status == HafalanStatus.completed`, lalu tulis baris sesi. Aman dari sisi timing: `ResetHafalan` cuma dipicu dari callback `onPageChanged` (swipe user), yang terjadi setelah listener ini jalan.

**Backend (`muslimly-be`):**
- `internal/features/sync/model/hafalan_session.go` — meniru `reading_activity.go`, `TableName() → "hafalan_sessions"`.
- Tambah di `sync/dto`, `sync/service/{interface,implementation}.go` (`BulkInsertHafalanSessions`, `GetHafalanSessions`), `sync/repository/{interface,implementation}.go` (`UpsertHafalanSessions`), `sync/handler/handler.go`.
- Daftarkan `&syncModel.HafalanSession{}` di `AutoMigrate(...)` pada `cmd/api/main.go`.
- **Migrasi baru** menambah unique index parsial pada `(user_id, timestamp)` / `(device_id, timestamp)` **sejak awal** — jangan cuma andalkan `clause.OnConflict{DoNothing:true}`. ⚠️ Ini bug nyata yang sudah pernah terjadi di `reading_activities`: `ID`-nya di-generate server (`gen_random_uuid()`), jadi `OnConflict` pada PK tidak pernah benar-benar match dan dedup diam-diam tidak jalan sampai ada migrasi susulan (`add_activity_dedup_index.sql`). Jangan diulang.
  - **[Riset #2 — dikonfirmasi]** File migrasi baru **wajib** ditambahkan ke slice `order` di `migrations/migrations.go`, atau `TestOrderCoversAllFiles` (`migrations/migrations_test.go:61`) akan gagal di CI. Ini bukan opsional, ini gate test yang sudah ada.
  - **[Riset #2]** Tidak ada test DB nyata di CI (`go test ./...` cuma jalan di ubuntu-latest tanpa Postgres/service container; test sync yang ada pakai `mockSyncRepo` hand-rolled). Artinya kebenaran unique index/`ON CONFLICT` di level DB **tidak** akan tertangkap oleh test — sama seperti bug `reading_activities` yang lolos CI dulu. Desain index dedup-nya harus benar dari awal (lihat poin di atas), bukan mengandalkan test untuk menangkapnya.
- Router: `POST /sync/hafalan-sessions`, `GET /sync/hafalan-sessions` di grup `sync` yang sudah ada (sudah pakai `OptionalJWTMiddleware`, identitas ganda `user_id`/`device_id` via `resolveIdentity()` di `sync/service/implementation.go:24`).
  - **[Riset #2]** Nama fungsi presedennya persis `BulkInsertActivities`/`GetActivities` (service) dan `UpsertActivities`/`GetActivities` (repository) — bukan `BulkInsertReadingActivities`. Pola penamaan yang diusulkan plan ini (`BulkInsertHafalanSessions`, `UpsertHafalanSessions`) sudah konsisten dengan gaya itu, tinggal ikuti.
  - **[Riset #2]** Grup `/sync` punya rate limiter per-user bersama (`r.config.RateLimit.Sync`, default 20 req) yang dipakai bareng semua endpoint sync lain. Bulk-insert hafalan session (bisa banyak baris per sesi baca) ikut kena kuota ini — jangan asumsikan tidak ada limit.
- `MigrateGuestData` (`sync/repository/implementation.go`, fungsi mulai ~baris 184) — tambah satu pass reassignment untuk `hafalan_sessions.device_id → user_id`, pakai guard `NOT EXISTS` timestamp yang sama seperti punya `reading_activities` (PASS 3, ~baris 238).
  - **[Riset #2]** Jangan lupa tambah field counter baru (misal `HafalanSessionsMigrated`) di `dto.MigrateGuestResponse` dan wiring-nya di handler `MigrateGuest` (`sync/handler/handler.go:~302`) — respons migrasi guest→user yang sudah ada punya `HistoriesUpdated`/`ActivitiesMigrated`/`BookmarksMigrated`/`SettingsMigrated`, jadi ini bukan cuma perubahan repository layer.
  - **[Riset #2]** Tidak ada row-level security di DB manapun di backend ini — ownership cuma dijaga di WHERE clause level aplikasi (`user_id = ?`/`device_id = ?`). Endpoint hafalan baru harus replikasi pola ini dengan hati-hati, tidak ada jaring pengaman di level DB.

**Kenapa diturunkan (derived), bukan tabel snapshot:** status "sudah hafal" per-surah bukan pointer tunggal yang mutable (beda dengan `reading_history` yang menyimpan "posisi terakhir baca") — itu rollup dari banyak sesi per-halaman, dan tabel snapshot akan jadi source of truth kedua yang bisa drift (misal setelah migrasi guest→user). Menghitungnya murah (setara biaya kalkulasi streak yang sudah ada, yang sejauh ini tidak pernah perlu di-cache).

**Keterbatasan yang diterima untuk v1:** sesi yang ditinggal/di-background sebelum `HafalanStatus.completed` tidak akan tercatat — sama seperti perilaku sekarang, bukan regresi. Muraja'ah (C) hanya akan melihat halaman yang benar-benar selesai.

---

## B. Target & Progress per-Surah/Juz (UI)

Proyeksi murni dari log A, tidak ada persistensi baru.

- `lib/src/features/quran/domain/utils/hafalan_progress_calculator.dart` — fungsi murni: `List<HafalanSession>` → status per-surah (`belum` / `sedang` / `sudah`) dan persentase per-juz, pakai `Ayah.juz`/`Ayah.page` (sudah ada di entity) + `QuranConstants`.
  - Aturan threshold (keputusan produk, belum ada preseden di codebase): surah dianggap `sudah` kalau setiap halamannya punya minimal satu sesi dengan `accuracy >= 0.75` (pakai ulang `ArabicTextMatcher.isPass()` di `arabic_text_matcher.dart:413` — sudah ada tapi belum dipakai; pastikan dulu tidak sedang dipakai di tempat lain untuk tujuan berbeda). Sesi baru dengan akurasi rendah **tidak** menurunkan status surah yang sudah `sudah` — sesi baru cuma menambah riwayat review, bukan menghapus status. Ini perlu eksplisit karena B dihitung ulang tiap load dan harus stabil.
- `lib/src/features/quran/presentation/bloc/hafalan_progress/` (cubit) — load lewat `DatabaseService.getHafalanSessions()`, masuk ke calculator; meniru bentuk `ReadingBloc._onLoadReadingHistory`.
- `lib/src/features/quran/presentation/pages/hafalan_progress_page.dart` + `hafalan_surah_progress_tile_widget.dart`.
- `app_router.dart` — route baru (misal `/quran/hafalan/progress`); entry point dari tombol baru di app bar `hafalan_page.dart` (saat ini cuma tombol back, baris 290-303) dan dari kartu dashboard di E.

---

## C. Penjadwalan Muraja'ah (Spaced Repetition)

**Unit review: (surah, halaman)** — sesuai granularitas logging di A. Kalau unitnya satu surah utuh, box level jadi campur aduk antar halaman yang dibaca di hari berbeda.

- `lib/src/features/quran/domain/utils/muraja_ah_scheduler.dart` — fungsi murni: sesi untuk satu (surah, halaman), diurutkan by timestamp → replay logika Leitner (lulus lewat `ArabicTextMatcher.isPass()` → box+1 dengan interval H+1/+3/+7/+14/+30; gagal → box kembali ke 1), bentuknya sama seperti kalkulasi streak ("fold" atas log yang immutable). Aman diturunkan dengan alasan yang sama seperti status A — tidak perlu field box-level yang disimpan terpisah.
  - Catatan performa: beda dengan scan streak yang dibatasi ~30-90 hari, ini me-replay seluruh riwayat per-unit. Hitung sekali per pemuatan sesi app (misal di dalam cubit dari B) dan cache di memori — jangan pernah di dalam `build()` widget.
- Item yang due diproyeksikan dari cubit B (tidak perlu bloc baru).
- **Notifikasi**: extend `callbackDispatcher()` yang sudah ada di `background_service.dart` (sudah jalan harian lewat satu task Workmanager `"muslimly_daily_refresh"`) untuk juga mengecek unit muraja'ah yang due dan memicu notifikasi. **Jangan** daftarkan task Workmanager periodik kedua — pakai ulang job harian yang sudah ada.
  - **[Riset #2 — risiko baru]** Task ini didaftarkan dengan `constraints: Constraints(networkType: NetworkType.connected)` (`background_service.dart:26`). Pengecekan due muraja'ah murni komputasi lokal (baca `hafalan_sessions` dari SQLite) dan tidak butuh network — tapi karena numpang di task yang sama, kalau device offline pas jadwal jalan (jam 3 pagi), **seluruh task termasuk notifikasi muraja'ah bisa di-skip Workmanager**, bukan cuma bagian yang butuh network. Perlu diputuskan: pisahkan constraint, atau terima risiko ini (device biasanya online jam segitu via wifi rumah) — jangan diam-diam terlewat begitu saja.
- Sediakan ID notifikasi terpisah (atau rentang ID) di `notification_service.dart` supaya tidak bentrok dengan ID notifikasi jadwal sholat yang sudah ada.
  - **[Riset #2]** Tidak ada registry/enum ID terpusat untuk dikonsultasi — skema aktual: `prayer_bloc.dart:211` pakai counter lokal `id++` (kira-kira ID 0-13 untuk 7 sholat), `notification_service.dart:673-683` hardcode ID `999` untuk notifikasi immediate (adhan/beep/silent), dan FCM foreground handler pakai `message.hashCode & 0x7fffffff`. Risiko tabrakan nyata kalau muraja'ah pilih ID kecil (0-13) atau `999`. **Rekomendasi konkret:** pakai rentang tetap yang jauh dari semua ini, misal offset `5000 + (surahNumber * 10 + pageIndex % 10)` atau sejenisnya — dan dokumentasikan di `notification_service.dart` sebagai komentar supaya jadi presenden untuk fitur berikutnya (belum ada presedennya sekarang).

---

## D. Mode Anak / "Guided"

**Tidak perlu ubah `ArabicTextMatcher.wordsMatch`** — fungsi ini tidak punya parameter leniency yang bisa diatur, dan memang tidak perlu; ketegasan ada sepenuhnya di `HafalanBloc`/UI:
- `hafalan_bloc.dart` — konstruktor saat ini **tanpa parameter** (`HafalanBloc() : super(const HafalanState())`, baris 81) — jadi `kidsMode` benar-benar field baru, tidak ada leniency knob lama yang bisa dipakai ulang. Tambah parameter constructor `final bool kidsMode`. Di `_onForceEvaluateMismatch` (baris 935-978, dikonfirmasi persis) dan `_silenceTimer` 2 detik (baris 651, guard di 646-649): kalau `kidsMode`, perpanjang timer dan/atau jadikan forced-mismatch no-op (tetap menunggu, bukan langsung ditandai merah).
  - **[Riset #2]** Tidak ada test otomatis untuk `hafalan_bloc.dart` sama sekali (folder `test/` cuma punya test prayer/notifikasi/tajweed/app-bar). Menambah cabang `kidsMode` di timer/forced-mismatch tanpa jaring pengaman test itu berisiko — minimal tambah satu widget/bloc test yang menutupi perilaku timer 2 detik di kedua mode sebelum dianggap selesai.
- `hafalan_single_page.dart` — terima prop `kidsMode`; ubah pemetaan warna mismatch (merah `0xFFEF5350`/`0xFFB71C1C`, baris 777 & 787, dikonfirmasi) jadi warna netral "belum pas" untuk mode anak, plus ukuran teks lebih besar untuk pembaca yang lebih muda.
- Persistensi: pakai `SettingsRepository`/`SettingsCubit` (infra yang sama dengan `getDailyReadingTarget`/`updateDailyTarget`, `settings_repository_impl.dart:102-112`) — catatan: ini disimpan di tabel sqlite `app_settings` (bukan SharedPreferences) dan **sudah otomatis sync** lewat `_syncSettingChanges()` → `/sync/settings`, jadi toggle ini otomatis ikut di semua device milik akun yang sama. Default yang tepat untuk device keluarga yang dipakai bersama.
- `hafalan_page.dart` — baca `context.read<SettingsCubit>().state.kidsMode` saat membuat `HafalanBloc(kidsMode: ...)`.

### [Riset #2] UX ramah-anak — bukan cuma "timer lebih longgar"

Riset kompetitor (Tarteel, Quran Companion, SABR, Thurayya) dan riset umum gamifikasi habit-tracking untuk anak menunjukkan beberapa pola yang lebih substansial daripada sekadar melonggarkan threshold:

1. **Jangan pakai merah/salah untuk mismatch di mode anak sama sekali** — bukan cuma "warna netral", tapi *framing*-nya: tampilkan sebagai "coba lagi, dengar dulu" (misal ikon telinga + warna kuning/abu lembut), bukan indikator kesalahan. Tarteel & kompetitor sejenis menyimpan histori kesalahan ("Historical Mistakes" / "Corrected Mistakes") sebagai *data untuk ditinjau nanti*, bukan feedback instan yang menghukum — pola ini lebih cocok direplikasi untuk mode anak daripada reveal merah real-time yang sudah ada untuk mode dewasa.
2. **Teks lebih besar sudah benar, tapi tambahkan juga audio-first fallback**: kompetitor kid-friendly konsisten mengandalkan audio narasi per-ayat sebagai penolong utama, bukan cuma teks besar — pertimbangkan tombol "dengar ayat ini" yang gampang dijangkau di `hafalan_single_page.dart` mode anak (bisa reuse `audio_player_widget.dart` yang sudah ada untuk murottal, tidak perlu infra baru).
3. **Silence timer yang diperpanjang perlu indikator visual "masih menunggu"**, bukan cuma diam — anak kecil gampang bingung apakah app-nya nge-freeze atau memang menunggu. Tambahkan indikator ringan (misal titik-titik berdenyut) selama periode tunggu yang diperpanjang.
4. **Tidak butuh perubahan skema/backend apa pun untuk poin 1-3** — semuanya di lapisan UI/state `HafalanBloc`/`hafalan_single_page.dart` yang sudah direncanakan, cuma memperdalam *bagaimana* kidsMode termanifestasi, bukan menambah sub-fitur baru.

---

## E. Gamifikasi + "Tampilan Orang Tua" Bersama

Meniru `generateReadingInsight()` (`reading_history_stats_widget.dart:9-118`, dikonfirmasi) tapi diperbaiki: fungsi itu pakai threshold exact-equality dua kali (`currentStreak == 5/7/14/30` baris 75-78, dan `daysWithProgress == 7` baris 88 — bug nyata, dikonfirmasi), jadi user yang skip tepat di hari milestone tidak pernah lihat banner-nya. Untuk hafalan, pakai `>=` plus flag ringan **lokal, tidak disync** "milestone sudah ditampilkan" (SharedPreferences, bukan bagian dari log yang disync — murni urusan dedup UI, bukan source of truth baru).

- `lib/src/features/quran/presentation/widgets/hafalan_history_stats_widget.dart` — fungsi baru `generateHafalanInsight({streak, totalAyatHafal, ...})`, fungsi murni di atas statistik turunan B/C. Hitung streak dengan cara yang sama seperti `_calculateLifetimeStats` (`reading_bloc.dart:182-264`, dikonfirmasi persis: tanggal unik dari log → walk hari berurutan dari anchor hari-ini/kemarin, tanpa counter tersimpan) — **jangan** sampai tidak sengaja pakai ulang data source streak-baca; itu log yang mirip secara struktur tapi independen.
  - **[Riset #2]** Basis tanggal streak yang sudah ada pakai `DateTime.now()` device-local tanpa normalisasi timezone/DST (dipakai konsisten di seluruh `reading_bloc.dart`). Ini pola lama yang sengaja direplikasi di sini, bukan regresi baru — tapi perlu disadari: user yang traveling lintas zona waktu dekat tengah malam bisa lihat streak-nya patah/lompat secara tidak konsisten. Cukup satu baris catatan, tidak perlu diperbaiki sekarang.
- `lib/src/features/dashboard/presentation/widgets/dashboard_hafalan_progress_card_widget.dart` — duplikat dari `DashboardDailyGoalCardWidget` (dikonfirmasi dumb widget reusable, constructor `progress/target/unitLabel/l10n`). Yang asli hardcode navigasi ke `/quran/history` (tap kartu, baris 56) dan `/quran/bookmarks` (teks "Read More", baris 384) — duplikatnya harus diarahkan ke route `/quran/hafalan/progress` dari B, bukan copy-paste link itu.
- `dashboard_page.dart` — sisipkan sebagai sibling tepat setelah blok `BlocBuilder<ReadingBloc,...>` yang membungkus `DashboardDailyGoalCardWidget` (baris 359-376, dikonfirmasi), sebelum hero card sholat. `ReadingBloc` di-provide di level router, bukan `dashboard_page.dart`: `app_router.dart` baris 86-102, di dalam `MultiBlocProvider` route `/dashboard` (bareng `PrayerBloc`/`BookmarkBloc`/`ArticleBloc`) — cubit B untuk kartu hafalan wajib didaftarkan di provider yang sama itu.
- Tampilan orang tua: halaman read-only biasa yang pakai ulang list per-surah + tanggal sesi terakhir + streak dari B. **Tidak ada sistem auth/profil baru** — app sudah menganggap "siapa pun yang pegang device ini" sebagai satu identitas (`user_id`/`device_id`), jadi ini cuma halaman tambahan, bukan fitur access-control.

### [Riset #2] Prinsip gamifikasi yang aman untuk konteks hafalan Quran + anak

Riset UX habit-tracking anak (umum) dan riset spesifik konteks hafalan Quran memberi beberapa prinsip konkret yang perlu masuk desain E, bukan cuma "tambah badge":

1. **Streak-shield, bukan streak yang gampang patah**: satu hari bolong per minggu **tidak** memutus streak. Ini mengatasi masalah nyata di `generateReadingInsight()` yang sudah ada (exact-equality bug di atas) dari sisi lain — bukan cuma soal kapan banner muncul, tapi soal apakah anak yang absen sehari (sakit, liburan) kehilangan seluruh progres motivasinya. Perlu diputuskan sebagai aturan turunan di `generateHafalanInsight()`/kalkulator streak, bukan cuma UI kosmetik.
2. **Jangan pakai leaderboard atau perbandingan antar-anak** — app ini single-identity per device (`user_id`/`device_id`), jadi secara arsitektur memang tidak ada leaderboard lintas-user pun. Cukup ditegaskan sebagai keputusan produk yang disengaja: gamifikasi tetap personal (progress vs diri sendiri), bukan kompetitif — konsisten dengan riset bahwa kompetisi menambah tekanan, bukan motivasi intrinsik, untuk konteks ibadah anak.
3. **Hindari framing "poin" yang terasa seperti menghitung pahala.** Ini pertimbangan spesifik konteks Islam yang tidak ada di riset gamifikasi generik: sumber pendidikan Islam menyoroti risiko gamifikasi ibadah yang membuat anak (atau orang tua) merasa app "menghitung amal" — bertentangan dengan nilai ikhlas. Implikasi praktis untuk copy/wording di `generateHafalanInsight()` dan kartu dashboard: pakai bahasa **konsistensi/kebiasaan** ("7 hari berturut-turut murajaah", "kamu sudah menyelesaikan halaman ini") — **hindari** istilah seperti "poin pahala" atau skor yang tersirat sebagai nilai ibadah. Badge/bintang untuk *konsistensi latihan* aman; framing yang menyerupai "skor ibadah" tidak.
4. **Histori kesalahan sebagai data netral, bukan hukuman** (lihat juga poin D.1) — kompetitor (Tarteel) melacak "Historical Mistakes"/"Corrected Mistakes" sebagai alat bantu tinjau-ulang, bukan skor yang dipajang. Kalau tampilan orang tua di atas menampilkan detail akurasi per sesi, framing-nya sebaiknya "bagian yang perlu diulang" bukan "nilai rapor" — supaya tidak berubah jadi tekanan orang tua ke anak.
5. **Opsional, di luar v1 kalau mau dieksplorasi nanti**: pola "virtual companion/quest" (anak merawat karakter yang tumbuh seiring progres) terbukti efektif untuk anak yang tidak termotivasi oleh progress bar biasa — tapi ini penambahan scope UI yang cukup besar (aset karakter, state companion), jadi taruh sebagai catatan masa depan, bukan bagian dari v1 E.

---

## F. Rekam & Setoran Hafalan (Audio)

**Kenapa ini penting, bukan cuma tambahan:** seluruh rencana A-E bergantung pada skor akurasi STT sebagai satu-satunya bukti hafalan. Budaya "setoran" (merekam bacaan untuk didengar ulang oleh ustadz/orang tua) adalah cara verifikasi yang sudah lazim dipakai, dan skor angka saja tidak bisa menggantikannya — apalagi di mode anak (D), di mana skor sengaja dilonggarkan sehingga makin tidak bisa dipakai sebagai bukti objektif. Rekaman audio mengisi celah itu: memberi bukti yang bisa didengar langsung oleh manusia, bukan cuma angka.

**Cek codebase (sudah diverifikasi):** belum ada kapasitas rekam suara di mana pun (`grep -rn "record|Recorder|flutter_sound"` di `lib/` dan `pubspec.yaml`: nihil). Tapi infrastruktur pendukung sudah ada semua: `path_provider` (penyimpanan file lokal), `just_audio` + `audio_service` (playback, sudah dipakai untuk murottal di `audio_player_widget.dart`), `share_plus` (share ke aplikasi lain), dan izin mikrofon sudah otomatis diminta oleh `speech_to_text` yang dipakai `HafalanBloc` — jadi rekaman tinggal menumpang izin yang sama, tidak perlu alur permission baru.

**Flutter:**
- Dependency baru: `record` (satu-satunya paket baru yang perlu ditambah di seluruh rencana ini).
- `hafalan_bloc.dart` — mulai rekam bersamaan dengan `StartListening`, berhenti saat `StopListening`/ayat selesai (`HafalanStatus.completed`). Hanya aktif kalau toggle "Rekam suara saat hafalan" (lihat di bawah) menyala.
- Simpan file `.m4a` via `path_provider` (app documents dir), nama file `{surahNumber}_{pageNumber}_{timestamp}.m4a`.
- Tambah field nullable `audioFilePath` di entity `hafalan_session.dart` dan tabel `hafalan_sessions` dari **A** — tidak perlu tabel/entity baru, cukup satu kolom tambahan pada skema yang sudah direncanakan. **Audio ini local-only untuk v1 — tidak di-upload/di-sync ke backend**, jadi tidak menyentuh `sync_api_service.dart` atau skema backend sama sekali.
- **Retensi (auto-purge)**: sebelum menulis `audioFilePath` baru untuk sebuah (surah, halaman), hapus file audio lama milik unit yang sama dari sesi sebelumnya — kecuali sesi itu ditandai "disimpan" (field `isAudioSaved bool` di `hafalan_session`). Jaga total ukuran storage tetap terkendali tanpa perlu job cleanup terpisah.
- **Toggle opt-in**: `SettingsRepository`/`SettingsCubit`, pola yang sama seperti `kidsMode` di **D** — `getRecordHafalan()/saveRecordHafalan(bool)`, default `false`. Saat pertama kali dinyalakan, tampilkan dialog sekali jalan yang menjelaskan: rekaman tersimpan di HP, tidak diupload otomatis, dan bisa dibagikan manual.
- **Playback**: widget kecil di halaman Progress (**B**) / riwayat sesi, reuse pola `audio_player_widget.dart` yang sudah ada untuk memutar file lokal.
- **Setoran (share manual)**: tombol share di tiap baris sesi yang punya rekaman → `SharePlus.instance.share()` (dikonfirmasi ini API `share_plus 13.1.0` yang aktual dipakai, lihat catatan migrasi di `TASK_HISTORY.md`; bukan `Share.instance.share()`) untuk kirim file `.m4a` ke WhatsApp/Telegram/dsb. Ini menggantikan kebutuhan sistem "review guru di dalam app" — user tetap kirim ke ustadz/orang tua lewat cara yang sudah biasa mereka pakai, tanpa perlu backend/akun guru-murid baru.

**Sengaja di luar scope v1** (inisiatif terpisah yang jauh lebih besar, jangan dikerjakan bersamaan): upload rekaman ke cloud storage/CDN + sistem review-di-dalam-app oleh guru, yang butuh object storage baru (mirip pola `cdn.muslimly.id` untuk font) dan sistem akun guru-murid — di luar model identitas `user_id`/`device_id` tunggal yang dipakai seluruh app saat ini.

---

## Verifikasi

- **Flutter**: `flutter analyze` setelah tiap sub-fitur; jalankan manual via `flutter run` — selesaikan satu halaman mushaf di mode Hafalan dan pastikan baris `hafalan_sessions` tertulis secara lokal, bertahan setelah restart app, ter-sync setelah login (cek `POST /sync/hafalan-sessions` terpanggil), dan muncul lagi setelah migrasi guest→user.
- **[Riset #2]** `BlocListener` completed-session (A) vs `ResetHafalan` (dipicu `onPageChanged`) bergantung urutan event Flutter yang tidak dijamin eksplisit oleh kode — keduanya kebetulan hidup di widget subtree yang sama sekarang. Test manual: swipe halaman tepat saat ayat terakhir baru saja selesai (state `completed`) dan pastikan sesi tetap tercatat, tidak ke-reset duluan.
- **[Riset #2]** Tidak ada test otomatis untuk `hafalan_bloc.dart` — sebelum menambah cabang `kidsMode` (D), tambahkan minimal satu bloc/widget test yang menutupi perilaku `_onForceEvaluateMismatch` dan silence timer di kedua mode, supaya perubahan ini tidak diam-diam merusak mode dewasa yang sudah ada.
- **Backend**: jalankan test suite Go (`go test ./...`) setelah menambah `hafalan_session.go` + migrasi; pastikan `TestOrderCoversAllFiles` (`migrations/migrations_test.go:61`) tetap lolos karena file migrasi baru harus didaftarkan di slice `order` pada `migrations/migrations.go`. **[Riset #2]** ingat juga: CI tidak punya Postgres nyata, jadi test unit (pola `mockSyncRepo`) tidak akan menangkap kesalahan desain unique index — verifikasi index dedup itu manual (jalankan migrasi + coba insert duplikat) sebelum deploy, bukan cuma andalkan `go test` hijau.
- **Mode anak**: test manual dengan persona anak — ucapkan ayat dengan pelafalan kurang tepat dan pastikan tidak ada tanda merah / tidak ada forced-timeout di mode anak, sementara mode ketat tetap berperilaku seperti sekarang.
- **Muraja'ah**: seed beberapa baris `hafalan_sessions` dengan tanggal mundur (atau ubah tanggal device) untuk memastikan satu halaman jadi "due" di boundary H+1/+3/+7 yang diharapkan, dan notifikasi harian memunculkannya tanpa mendaftarkan task Workmanager kedua.
- **Kartu dashboard**: cek visual kartu baru tampil benar di dashboard berdampingan dengan kartu target baca yang sudah ada, dan pill "Completed" + target navigasinya berfungsi end-to-end.
- **Rekam & setoran**: nyalakan toggle rekam, selesaikan satu halaman, pastikan file `.m4a` tersimpan dan bisa diputar ulang; selesaikan halaman yang sama lagi dan pastikan rekaman lama otomatis terhapus (kecuali sudah ditandai simpan); coba tombol share dan pastikan file sampai utuh di aplikasi tujuan. Pastikan toggle default OFF pada instalasi baru.

---

## Sumber riset UX #2 (kid-friendly & gamifikasi)

- [Best Quran Memorization Apps for Kids & Teens (2026) — SABR](https://get-sabr.com/blog/best-quran-memorization-apps-for-kids-and-teens)
- [Quran Memorization Apps: Best Tools for Hifz in 2026 — SimplyIslam](https://simplyislam.sg/quran-memorization-apps/)
- [Tarteel Introduces Family Plan — Muslim Tech Wire](https://www.muslimtechwire.com/tarteel-introduces-family-plan)
- [Update Fitur Tarteel AI 2026 — Yokersane](https://yokersane.com/update-fitur-tarteel-ai-2026-hafalan-quran/)
- [How Streaks Leverages Gamification to Boost Retention — Trophy](https://trophy.so/blog/streaks-gamification-case-study)
- [The 8 best family habit tracking apps in 2026 — Our Family Habits](https://www.ourfamilyhabits.com/articles/best-family-habit-tracking-apps)
- [Educational Kids Apps Gamification: No Backend Guide — Lycore](https://www.lycore.com/blog/educational-kids-apps-gamification/)
- [Dalil Tentang Ikhlas, Pondasi Utama Diterimanya Hafalan — PTQ Syekh Ali Jaber](https://ptqsyekhalijaber.com/dalil-tentang-ikhlas-pondasi-utama-diterimanya-amal-dan-hafalan-al-quran/)
