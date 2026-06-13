# 📘 Dokumentasi API — HSIL Attendance System (Absen!)

> **Versi**: 1.0.0  
> **Firebase Project**: `hsil-attendance`  
> **Platform**: Android (Flutter)  
> **Arsitektur**: Clean Architecture (Domain → Data → Presentation)

---

## Daftar Isi

- [1. Ringkasan Sistem](#1-ringkasan-sistem)
- [2. Firebase Cloud Functions API](#2-firebase-cloud-functions-api)
  - [2.1 createEmployeeProfile](#21-createemployeeprofile)
  - [2.2 requestPasswordReset](#22-requestpasswordreset)
  - [2.3 verifyOtpAndResetPassword](#23-verifyotpandresetpassword)
  - [2.4 markDailyAlpha](#24-markdailyalpha)
  - [2.5 createClockInNotification](#25-createclockinnotification)
  - [2.6 sendBroadcastNotification](#26-sendbroadcastnotification)
  - [2.7 deleteEmployeeAuth](#27-deleteemployeeauth)
- [3. Firestore Database Schema](#3-firestore-database-schema)
  - [3.1 Collection: users](#31-collection-users)
  - [3.2 Collection: attendance](#32-collection-attendance)
  - [3.3 Collection: notifications](#33-collection-notifications)
  - [3.4 Collection: leave_requests](#34-collection-leave_requests)
  - [3.5 Collection: broadcast_messages](#35-collection-broadcast_messages)
  - [3.6 Collection: passwordResets](#36-collection-passwordresets)
- [4. Domain Layer — Entities](#4-domain-layer--entities)
  - [4.1 AppUser](#41-appuser)
  - [4.2 AttendanceRecord](#42-attendancerecord)
  - [4.3 GPSValidationResult](#43-gpsvalidationresult)
  - [4.4 FaceValidationResult](#44-facevalidationresult)
  - [4.5 LeaveRequest](#45-leaverequest)
  - [4.6 NotificationEntity](#46-notificationentity)
  - [4.7 RegistrationRequest](#47-registrationrequest)
- [5. Domain Layer — Repository Contracts](#5-domain-layer--repository-contracts)
  - [5.1 AuthRepository](#51-authrepository)
  - [5.2 UserRepository](#52-userrepository)
  - [5.3 AttendanceRepository](#53-attendancerepository)
  - [5.4 LocationRepository](#54-locationrepository)
  - [5.5 NotificationRepository](#55-notificationrepository)
  - [5.6 LeaveRepository](#56-leaverepository)
  - [5.7 AdminRepository](#57-adminrepository)
- [6. Domain Layer — Use Cases](#6-domain-layer--use-cases)
- [7. Error Handling](#7-error-handling)
- [8. Konfigurasi & Konstanta](#8-konfigurasi--konstanta)
- [9. Routing / Navigasi](#9-routing--navigasi)

---

## 1. Ringkasan Sistem

**HSIL Attendance System (Absen!)** adalah aplikasi absensi karyawan berbasis Android yang dibangun menggunakan **Flutter** dan **Firebase**. Fitur utama:

- ✅ **Clock-in / Clock-out** dengan validasi GPS (geofence) dan selfie wajah
- 📍 **Validasi Lokasi GPS** — memastikan karyawan berada dalam radius 500m dari lokasi kantor
- 📋 **Riwayat Kehadiran** — laporan bulanan dengan filter status
- 📝 **Pengajuan Izin/Cuti** — alur persetujuan oleh admin
- 🔐 **Autentikasi** — login dengan NIK, registrasi, lupa password (OTP via email)
- 👤 **Profil Karyawan** — edit data diri, ubah password
- 🛡️ **Panel Admin** — manajemen karyawan, log kehadiran, KPI, peta live tracking
- 📢 **Broadcast Notifikasi** — pengumuman massal ke seluruh karyawan via FCM

### Tech Stack

| Layer | Teknologi |
|-------|-----------|
| Frontend | Flutter (Dart) |
| State Management | Provider (ChangeNotifier) |
| Backend | Firebase Cloud Functions v2 (TypeScript) |
| Database | Cloud Firestore |
| Authentication | Firebase Auth (Email/Password) |
| Push Notification | Firebase Cloud Messaging (FCM) |
| Email Service | Nodemailer (Gmail SMTP) |
| GPS | Geolocator + Google Maps SDK |
| Face Detection | Google ML Kit |

---

## 2. Firebase Cloud Functions API

Semua Cloud Functions menggunakan **Firebase Functions v2** dan di-deploy ke project `hsil-attendance`.

### 2.1 `createEmployeeProfile`

Membuat profil karyawan baru di Firestore.

| Property | Nilai |
|----------|-------|
| **Trigger** | `onCall` (Callable) |
| **Auth Required** | ✅ Ya — Hanya Admin |
| **Region** | Default (us-central1) |

**Request Parameters:**

```typescript
{
  uid: string;        // Firebase Auth UID (wajib)
  nik: string;        // NIK 10 digit (wajib)
  name: string;       // Nama lengkap (wajib)
  email: string;      // Email karyawan (wajib)
  role: "employee" | "admin";  // Role (wajib)
  department: string; // Departemen (wajib)
  position: string;   // Jabatan (wajib)
  phone?: string;     // No. HP (opsional)
  shiftStart?: string; // Jam masuk, default "08:00" (opsional)
  shiftEnd?: string;   // Jam pulang, default "17:00" (opsional)
}
```

**Response (Success):**

```json
{ "ok": true }
```

**Error Codes:**

| Code | Pesan | Penyebab |
|------|-------|----------|
| `unauthenticated` | Login dibutuhkan. | Tidak ada auth token |
| `permission-denied` | Hanya admin aktif yang boleh menjalankan aksi ini. | Bukan admin / admin non-aktif |
| `invalid-argument` | NIK harus 10 digit. | NIK tidak sesuai format |
| `invalid-argument` | Role tidak valid. | Role selain `employee`/`admin` |
| `invalid-argument` | Payload karyawan belum lengkap. | Field wajib kosong |

**Contoh Pemanggilan (Dart):**

```dart
final functions = FirebaseFunctions.instance;
final result = await functions.httpsCallable('createEmployeeProfile').call({
  'uid': 'abc123',
  'nik': '1234567890',
  'name': 'John Doe',
  'email': 'john@hsil.factory',
  'role': 'employee',
  'department': 'Production',
  'position': 'Operator',
});
```

---

### 2.2 `requestPasswordReset`

Mengirim kode OTP 6-digit ke email karyawan untuk proses reset password.

| Property | Nilai |
|----------|-------|
| **Trigger** | `onCall` (Callable) |
| **Auth Required** | ❌ Tidak |

**Request Parameters:**

```typescript
{
  nik: string;  // NIK (10 digit) atau alamat email
}
```

**Response (Success):**

```json
{
  "ok": true,
  "emailHint": "jo***@hsil.factory",
  "resolvedNik": "1234567890"
}
```

**Error Codes:**

| Code | Pesan | Penyebab |
|------|-------|----------|
| `invalid-argument` | Data tidak valid. | `nik` kosong |
| `invalid-argument` | NIK tidak valid. | Panjang NIK ≠ 10 |
| `not-found` | Karyawan tidak ditemukan. | NIK/email tidak ada di database |
| `failed-precondition` | Karyawan belum memiliki email aktif. | User tidak punya email valid |
| `internal` | Gagal mengirim email OTP. | Kegagalan SMTP/Nodemailer |

**Detail Teknis:**
- OTP disimpan di collection `passwordResets/{nik}` dengan masa berlaku **15 menit**
- Email dikirim via Nodemailer (Gmail SMTP)
- Email hint berformat: 2 huruf pertama + asterisk + domain (contoh: `jo***@hsil.factory`)

---

### 2.3 `verifyOtpAndResetPassword`

Memverifikasi kode OTP dan mengubah password karyawan.

| Property | Nilai |
|----------|-------|
| **Trigger** | `onCall` (Callable) |
| **Auth Required** | ❌ Tidak |

**Request Parameters:**

```typescript
{
  nik: string;         // NIK karyawan
  otp: string;         // Kode OTP 6-digit
  newPassword: string; // Password baru
}
```

**Response (Success):**

```json
{ "ok": true }
```

**Error Codes:**

| Code | Pesan | Penyebab |
|------|-------|----------|
| `invalid-argument` | Data tidak lengkap. | Salah satu field kosong |
| `not-found` | Kode OTP tidak valid atau sudah kadaluarsa. | Dokumen reset tidak ditemukan |
| `resource-exhausted` | Terlalu banyak percobaan yang salah. Silakan minta OTP baru. | Percobaan ≥ 3 kali |
| `failed-precondition` | Kode OTP sudah kadaluarsa. | OTP melebihi 15 menit |
| `invalid-argument` | Kode OTP salah. | OTP tidak cocok |
| `not-found` | Karyawan tidak ditemukan. | NIK tidak terdaftar |
| `internal` | Gagal mengubah password. | Firebase Auth gagal update |

**Detail Teknis:**
- Maksimal **3 percobaan** salah. Jika melebihi, dokumen OTP dihapus
- Setelah verifikasi berhasil, password diupdate melalui Firebase Admin Auth (`getAuth().updateUser()`)
- Dokumen reset dihapus setelah sukses

---

### 2.4 `markDailyAlpha`

Menandai karyawan yang tidak hadir (alpha) secara otomatis di akhir hari.

| Property | Nilai |
|----------|-------|
| **Trigger** | `onSchedule` (Terjadwal) |
| **Schedule** | `50 23 * * 1-5` (Senin–Jumat, 23:50 WIB) |
| **Timezone** | `Asia/Jakarta` |
| **Retry** | 1 kali |

**Behavior:**
1. Mengambil tanggal hari ini dalam zona waktu WIB (UTC+7)
2. Mengambil semua user aktif (`isActive == true`)
3. Mengambil record kehadiran hari ini dan daftar izin yang disetujui
4. Untuk setiap karyawan aktif yang **belum absen** dan **tidak sedang izin**, membuat record `attendance` dengan status `"alpha"`

**Firestore Collections Diakses:**
- `users` (read) — daftar karyawan aktif
- `attendance` (read + write) — cek kehadiran dan buat record alpha
- `leave_requests` (read) — cek izin yang disetujui

---

### 2.5 `createClockInNotification`

Membuat notifikasi otomatis saat karyawan melakukan clock-in.

| Property | Nilai |
|----------|-------|
| **Trigger** | `onDocumentCreated("attendance/{attendanceId}")` |
| **Auth Required** | N/A (Trigger otomatis) |

**Behavior:**
Ketika dokumen baru dibuat di collection `attendance`, fungsi ini otomatis membuat dokumen notifikasi di collection `notifications`:

```json
{
  "userId": "<employeeId>",
  "type": "clock_in_success",
  "title": "Clock-in tersimpan",
  "body": "Absensi 2026-06-13 berhasil tercatat.",
  "isRead": false,
  "data": {
    "attendanceId": "<attendanceId>",
    "status": "<hadir|telat>"
  },
  "createdAt": "<server_timestamp>"
}
```

---

### 2.6 `sendBroadcastNotification`

Mengirim notifikasi push (FCM) ke seluruh karyawan saat admin membuat pengumuman baru.

| Property | Nilai |
|----------|-------|
| **Trigger** | `onDocumentCreated("broadcast_messages/{docId}")` |
| **Auth Required** | N/A (Trigger otomatis) |

**Behavior:**
Ketika dokumen baru ditambahkan ke collection `broadcast_messages`, fungsi ini mengirim push notification ke FCM topic `"all_employees"`.

**FCM Payload:**

```json
{
  "notification": {
    "title": "<judul pengumuman>",
    "body": "<isi pesan>"
  },
  "topic": "all_employees"
}
```

---

### 2.7 `deleteEmployeeAuth`

Menghapus akun Firebase Auth secara otomatis saat dokumen user dihapus dari Firestore.

| Property | Nilai |
|----------|-------|
| **Trigger** | `onDocumentDeleted("users/{userId}")` |
| **Auth Required** | N/A (Trigger otomatis) |

**Behavior:**
- Saat dokumen di collection `users` dihapus (oleh admin), fungsi ini otomatis memanggil `getAuth().deleteUser(userId)` untuk menghapus akun Auth terkait
- Jika user sudah tidak ada di Auth (`auth/user-not-found`), error diabaikan

---

## 3. Firestore Database Schema

### 3.1 Collection: `users`

**Document ID**: Firebase Auth UID (`{userId}`)

| Field | Tipe | Wajib | Default | Deskripsi |
|-------|------|-------|---------|-----------|
| `userId` | `string` | ✅ | — | Sama dengan document ID |
| `nik` | `string` | ✅ | — | NIK karyawan (10 digit) |
| `name` | `string` | ✅ | `'HSIL Employee'` | Nama lengkap |
| `email` | `string` | ✅ | — | Format: `{NIK}@hsil.factory` |
| `role` | `string` | ✅ | `'employee'` | Enum: `'employee'`, `'admin'` |
| `department` | `string` | ✅ | `'Production'` | Departemen |
| `position` | `string` | ✅ | `'Operator'` | Jabatan |
| `phone` | `string` | ❌ | `null` | Nomor HP |
| `photoUrl` | `string` | ❌ | `null` | URL foto profil |
| `shiftStart` | `string` | ✅ | `'08:00'` | Jam masuk (format `HH:mm`) |
| `shiftEnd` | `string` | ✅ | `'17:00'` | Jam pulang (format `HH:mm`) |
| `isActive` | `boolean` | ✅ | `true` | Status aktif karyawan |
| `createdAt` | `timestamp` | ❌ | Server timestamp | Waktu pembuatan |
| `updatedAt` | `timestamp` | ❌ | Server timestamp | Waktu pembaruan terakhir |

**Security Rules:**

```
allow read:   if isOwner(userId) || isAdmin();
allow create: if isOwner(userId);
allow update: if isOwner(userId) || isAdmin();
allow delete: if isAdmin();
```

---

### 3.2 Collection: `attendance`

**Document ID**: `{employeeId}_{yyyy-MM-dd}` (deterministik)

| Field | Tipe | Wajib | Default | Deskripsi |
|-------|------|-------|---------|-----------|
| `id` | `string` | ✅ | — | Sama dengan document ID |
| `employeeId` | `string` | ✅ | — | Firebase Auth UID |
| `employeeName` | `string` | ✅ | — | Nama karyawan |
| `date` | `string` | ✅ | — | Format: `yyyy-MM-dd` |
| `clockIn` | `timestamp` | ❌ | `null` | Waktu clock-in |
| `clockOut` | `timestamp` | ❌ | `null` | Waktu clock-out |
| `clockInLat` | `number` | ❌ | `null` | Latitude GPS saat clock-in |
| `clockInLng` | `number` | ❌ | `null` | Longitude GPS saat clock-in |
| `clockOutLat` | `number` | ❌ | `null` | Latitude GPS saat clock-out |
| `clockOutLng` | `number` | ❌ | `null` | Longitude GPS saat clock-out |
| `clockInDistance` | `number` | ❌ | `null` | Jarak ke kantor (meter) saat clock-in |
| `clockOutDistance` | `number` | ❌ | `null` | Jarak ke kantor (meter) saat clock-out |
| `clockInImageUrl` | `string` | ❌ | `null` | URL selfie saat clock-in |
| `clockOutImageUrl` | `string` | ❌ | `null` | URL selfie saat clock-out |
| `status` | `string` | ✅ | `'alpha'` | Enum: `'hadir'`, `'telat'`, `'izin'`, `'sakit'`, `'alpha'` |
| `gpsStatus` | `string` | ✅ | `'unknown'` | Enum: `'IN_AREA'`, `'OUTSIDE_AREA'`, `'N/A'` |
| `createdAt` | `timestamp` | ❌ | Server timestamp | Waktu pembuatan |
| `updatedAt` | `timestamp` | ❌ | Server timestamp | Waktu pembaruan terakhir |

**Security Rules:**

```
allow read:   if isAuth();
allow create: if isAuth() && request.resource.data.employeeId == request.auth.uid;
allow update: if isAdmin();
allow delete: if false;  // Tidak pernah bisa dihapus
```

**Composite Indexes:**

| Fields | Order |
|--------|-------|
| `employeeId` ASC + `date` DESC | Query riwayat kehadiran |
| `employeeId` ASC + `date` ASC | Query rentang tanggal |
| `status` ASC + `date` DESC | Filter berdasarkan status |

---

### 3.3 Collection: `notifications`

**Document ID**: Auto-generated

| Field | Tipe | Wajib | Default | Deskripsi |
|-------|------|-------|---------|-----------|
| `userId` | `string` | ✅ | — | Target user UID |
| `title` | `string` | ✅ | `''` | Judul notifikasi |
| `body` | `string` | ✅ | `''` | Isi notifikasi |
| `type` | `string` | ✅ | `'info'` | Enum: `'reminder'`, `'success'`, `'failure'`, `'info'`, `'clock_in_success'` |
| `isRead` | `boolean` | ✅ | `false` | Status sudah dibaca |
| `data` | `map` | ❌ | `{}` | Payload tambahan (contoh: `{attendanceId, status}`) |
| `createdAt` | `timestamp` | ✅ | Server timestamp | Waktu pembuatan |

**Composite Indexes:**

| Fields | Order |
|--------|-------|
| `userId` ASC + `createdAt` DESC | Query notifikasi per user |

---

### 3.4 Collection: `leave_requests`

**Document ID**: Custom string

| Field | Tipe | Wajib | Default | Deskripsi |
|-------|------|-------|---------|-----------|
| `id` | `string` | ✅ | — | Sama dengan document ID |
| `employeeId` | `string` | ✅ | — | Firebase Auth UID pengaju |
| `employeeName` | `string` | ✅ | — | Nama pengaju |
| `startDate` | `string` | ✅ | — | Tanggal mulai (`yyyy-MM-dd`) |
| `endDate` | `string` | ✅ | — | Tanggal selesai (`yyyy-MM-dd`) |
| `type` | `string` | ✅ | `'sakit'` | Enum: `'sakit'`, `'cuti'`, `'keperluanPribadi'` |
| `reason` | `string` | ✅ | — | Alasan pengajuan |
| `status` | `string` | ✅ | `'pending'` | Enum: `'pending'`, `'approved'`, `'rejected'` |
| `attachmentUrl` | `string` | ❌ | `null` | URL lampiran (surat dokter, dll) |
| `reviewedBy` | `string` | ❌ | `null` | UID admin yang mereview |
| `reviewerName` | `string` | ❌ | `null` | Nama admin yang mereview |
| `reviewNote` | `string` | ❌ | `null` | Catatan dari admin |
| `createdAt` | `timestamp` | ❌ | Server timestamp | Waktu pembuatan |
| `updatedAt` | `timestamp` | ❌ | Server timestamp | Waktu pembaruan |

---

### 3.5 Collection: `broadcast_messages`

**Document ID**: Auto-generated

| Field | Tipe | Wajib | Deskripsi |
|-------|------|-------|-----------|
| `title` | `string` | ✅ | Judul pengumuman |
| `body` | `string` | ✅ | Isi pesan |
| `senderId` | `string` | ✅ | UID admin pengirim |
| `senderName` | `string` | ✅ | Nama admin pengirim |
| `createdAt` | `timestamp` | ✅ | Waktu pengiriman (server timestamp) |

---

### 3.6 Collection: `passwordResets`

**Document ID**: NIK karyawan

| Field | Tipe | Wajib | Deskripsi |
|-------|------|-------|-----------|
| `otp` | `string` | ✅ | Kode OTP 6-digit |
| `expiresAt` | `timestamp` | ✅ | Waktu kadaluarsa (15 menit dari pembuatan) |
| `attempts` | `number` | ✅ | Jumlah percobaan (maks 3) |

---

## 4. Domain Layer — Entities

### 4.1 `AppUser`

Representasi profil karyawan/admin yang terautentikasi.

```dart
class AppUser {
  final String userId;       // Firebase Auth UID
  final String nik;          // NIK 10-digit
  final String name;         // Nama lengkap
  final String email;        // Email
  final UserRole role;       // employee | admin
  final String department;   // Departemen
  final String position;     // Jabatan
  final String? phone;       // No. HP (opsional)
  final String? photoUrl;    // URL foto (opsional)
  final String shiftStart;   // Jam masuk (HH:mm)
  final String shiftEnd;     // Jam pulang (HH:mm)
  final bool isActive;       // Status aktif
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isAdmin => role == UserRole.admin;
}

enum UserRole { employee, admin }
```

---

### 4.2 `AttendanceRecord`

Representasi satu record kehadiran karyawan.

```dart
class AttendanceRecord {
  final String id;              // Format: {employeeId}_{yyyy-MM-dd}
  final String employeeId;      // Firebase Auth UID
  final String employeeName;
  final String date;            // Format: yyyy-MM-dd
  final DateTime? clockIn;      // Waktu clock-in
  final DateTime? clockOut;     // Waktu clock-out
  final double? clockInLat;     // Latitude clock-in
  final double? clockInLng;     // Longitude clock-in
  final double? clockOutLat;    // Latitude clock-out
  final double? clockOutLng;    // Longitude clock-out
  final double? clockInDistance; // Jarak dari kantor (meter)
  final double? clockOutDistance;
  final String? clockInImageUrl;  // URL selfie clock-in
  final String? clockOutImageUrl; // URL selfie clock-out
  final String status;          // hadir | telat | izin | sakit | alpha
  final String gpsStatus;       // IN_AREA | OUTSIDE_AREA | N/A
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasClockedIn => clockIn != null;
  bool get hasClockedOut => clockOut != null;
  bool get isComplete => hasClockedIn && hasClockedOut;
}
```

**Status Kehadiran:**

| Status | Warna | Deskripsi |
|--------|-------|-----------|
| `hadir` | 🟢 Hijau | Hadir tepat waktu (≤ 15 menit dari shift start) |
| `telat` | 🟡 Kuning | Terlambat (> 15 menit dari shift start) |
| `izin` | 🔵 Biru | Izin/cuti yang disetujui |
| `sakit` | 🔵 Biru | Sakit |
| `alpha` | 🔴 Merah | Tidak hadir tanpa keterangan |

---

### 4.3 `GPSValidationResult`

Hasil validasi lokasi GPS terhadap geofence kantor.

```dart
class GPSValidationResult {
  final bool isInArea;         // Dalam radius kantor?
  final double distanceMeters; // Jarak dari kantor (meter)
  final double latitude;       // Latitude saat ini
  final double longitude;      // Longitude saat ini
  final String status;         // IN_AREA | OUTSIDE_AREA
  final DateTime timestamp;    // Waktu validasi
  final double? accuracy;      // Akurasi GPS (meter)
}
```

**Geofence Configuration:**

| Parameter | Nilai |
|-----------|-------|
| Lokasi Kantor | Telkom University |
| Latitude | `-6.973007` |
| Longitude | `107.630713` |
| Radius | `500` meter |

---

### 4.4 `FaceValidationResult`

Hasil validasi foto selfie menggunakan ML Kit Face Detection.

```dart
class FaceValidationResult {
  final bool isValid;         // Semua validasi lolos?
  final bool faceDetected;    // Wajah terdeteksi?
  final bool isSingleFace;   // Tepat satu wajah?
  final bool isNotBlurry;    // Foto tidak blur?
  final bool hasGoodLighting; // Pencahayaan baik?
  final String? errorMessage;  // Pesan error (jika gagal)
  final Uint8List? capturedImage; // Bytes gambar (jika valid)
}
```

---

### 4.5 `LeaveRequest`

Representasi pengajuan izin/cuti.

```dart
class LeaveRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final String startDate;      // yyyy-MM-dd
  final String endDate;        // yyyy-MM-dd
  final LeaveType type;        // sakit | cuti | keperluanPribadi
  final String reason;
  final String? attachmentUrl;
  final LeaveStatus status;    // pending | approved | rejected
  final String? reviewedBy;    // UID admin reviewer
  final String? reviewerName;
  final String? reviewNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

enum LeaveType { sakit, cuti, keperluanPribadi }
enum LeaveStatus { pending, approved, rejected }
```

---

### 4.6 `NotificationEntity`

Representasi notifikasi dalam aplikasi.

```dart
class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final String type;      // reminder | success | failure | info
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic> data;
}
```

---

### 4.7 `RegistrationRequest`

Data yang diperlukan untuk mendaftarkan karyawan baru.

```dart
class RegistrationRequest {
  final String nik;
  final String name;
  final String email;
  final String password;
  final String department;
  final String position;
  final String? phone;
}
```

---

## 5. Domain Layer — Repository Contracts

### 5.1 `AuthRepository`

Kontrak untuk operasi autentikasi.

```dart
abstract interface class AuthRepository {
  /// Stream perubahan status autentikasi
  Stream<AppUser?> authStateChanges();

  /// Mengambil user yang tersimpan di cache lokal
  Future<AppUser?> getCachedUser();

  /// Mengambil NIK yang tersimpan (fitur "Remember Me")
  Future<String?> getRememberedNik();

  /// Cek status "Remember Me"
  Future<bool> getRememberMe();

  /// Login dengan NIK/email dan password
  Future<AppResult<AppUser>> signIn({
    required String identifier,
    required String password,
    required bool rememberMe,
  });

  /// Registrasi karyawan baru
  Future<AppResult<AppUser>> registerEmployee(RegistrationRequest request);

  /// Kirim email reset password (Firebase Auth)
  Future<AppResult<void>> sendPasswordReset(String nikOrEmail);

  /// Logout
  Future<AppResult<void>> signOut();

  /// Update cache user lokal
  Future<void> updateCachedUser(AppUser user);
}
```

---

### 5.2 `UserRepository`

Kontrak untuk operasi profil pengguna.

```dart
abstract interface class UserRepository {
  /// Ambil profil user dari Firestore
  Future<AppResult<AppUser>> getUserProfile(String userId);

  /// Update field profil (name, phone, dll)
  Future<AppResult<AppUser>> updateProfile({
    required String userId,
    required Map<String, dynamic> fields,
  });

  /// Ubah password setelah re-autentikasi
  Future<AppResult<void>> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  });
}
```

---

### 5.3 `AttendanceRepository`

Kontrak untuk operasi kehadiran.

```dart
abstract interface class AttendanceRepository {
  /// Clock-in dengan validasi GPS dan selfie
  Future<AppResult<AttendanceRecord>> clockIn({
    required String employeeId,
    required String employeeName,
    required GPSValidationResult gpsResult,
    required String imageUrl,
  });

  /// Clock-out dengan validasi GPS dan selfie
  Future<AppResult<AttendanceRecord>> clockOut({
    required String attendanceId,
    required GPSValidationResult gpsResult,
    required String imageUrl,
  });

  /// Ambil record kehadiran hari ini
  Future<AppResult<AttendanceRecord?>> getTodayAttendance(String employeeId);

  /// Stream real-time kehadiran hari ini
  Stream<AttendanceRecord?> watchTodayAttendance(String employeeId);

  /// Ambil riwayat kehadiran berdasarkan rentang tanggal
  Future<AppResult<List<AttendanceRecord>>> getAttendanceByDateRange({
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Hitung statistik kehadiran mingguan
  /// Returns: {hadir: n, telat: n, izin: n, alpha: n}
  Future<AppResult<Map<String, int>>> getWeeklyStats(String employeeId);
}
```

---

### 5.4 `LocationRepository`

Kontrak untuk operasi GPS.

```dart
abstract interface class LocationRepository {
  /// Validasi lokasi saat ini terhadap geofence kantor
  Future<GPSValidationResult> validateCurrentLocation();

  /// Stream validasi lokasi real-time
  Stream<GPSValidationResult> watchLocationStream();

  /// Cek apakah layanan lokasi (GPS) aktif
  Future<bool> isLocationServiceEnabled();

  /// Minta izin akses lokasi
  Future<bool> requestLocationPermission();

  /// Cek apakah izin lokasi sudah diberikan
  Future<bool> hasLocationPermission();
}
```

---

### 5.5 `NotificationRepository`

Kontrak untuk operasi notifikasi.

```dart
abstract interface class NotificationRepository {
  /// Ambil semua notifikasi user
  Future<AppResult<List<NotificationEntity>>> getNotifications(String userId);

  /// Simpan notifikasi baru
  Future<AppResult<void>> saveNotification({
    required String userId,
    required NotificationEntity notification,
  });

  /// Tandai satu notifikasi sebagai sudah dibaca
  Future<AppResult<void>> markAsRead({
    required String userId,
    required String notificationId,
  });

  /// Tandai semua notifikasi sebagai sudah dibaca
  Future<AppResult<void>> markAllAsRead(String userId);

  /// Stream jumlah notifikasi belum dibaca
  Stream<int> watchUnreadCount(String userId);
}
```

---

### 5.6 `LeaveRepository`

Kontrak untuk operasi izin/cuti.

```dart
abstract interface class LeaveRepository {
  /// Ajukan izin/cuti baru
  Future<AppResult<LeaveRequest>> submitLeaveRequest({
    required String employeeId,
    required String employeeName,
    required String startDate,
    required String endDate,
    required LeaveType type,
    required String reason,
    String? attachmentUrl,
  });

  /// Ambil semua pengajuan izin (Admin)
  Future<AppResult<List<LeaveRequest>>> getAllLeaveRequests();

  /// Ambil pengajuan izin milik sendiri
  Future<AppResult<List<LeaveRequest>>> getMyLeaveRequests(String employeeId);

  /// Ambil pengajuan yang menunggu persetujuan (Admin)
  Future<AppResult<List<LeaveRequest>>> getPendingLeaveRequests();

  /// Setujui pengajuan izin (Admin)
  Future<AppResult<LeaveRequest>> approveLeaveRequest({
    required String requestId,
    required String adminId,
    required String adminName,
    String? note,
  });

  /// Tolak pengajuan izin (Admin)
  Future<AppResult<LeaveRequest>> rejectLeaveRequest({
    required String requestId,
    required String adminId,
    required String adminName,
    String? note,
  });
}
```

---

### 5.7 `AdminRepository`

Kontrak untuk operasi khusus admin.

```dart
abstract class AdminRepository {
  /// Ambil semua karyawan
  Future<AppResult<List<AppUser>>> getAllEmployees();

  /// Ambil kehadiran hari ini (semua karyawan)
  Future<AppResult<List<AttendanceRecord>>> getTodayAttendance();

  /// Ambil kehadiran karyawan tertentu berdasarkan rentang tanggal
  Future<AppResult<List<AttendanceRecord>>> getEmployeeAttendance(
    String employeeId, DateTime startDate, DateTime endDate);

  /// Ambil kehadiran semua karyawan berdasarkan rentang tanggal
  Future<AppResult<List<AttendanceRecord>>> getAttendanceRange(
    DateTime startDate, DateTime endDate);

  /// Ubah role karyawan
  Future<AppResult<void>> updateEmployeeRole(String employeeId, UserRole newRole);

  /// Tambah karyawan baru
  Future<AppResult<void>> addEmployee(RegistrationRequest request);

  /// Hapus karyawan (memicu deleteEmployeeAuth Cloud Function)
  Future<AppResult<void>> deleteEmployee(String employeeId);
}
```

---

## 6. Domain Layer — Use Cases

Setiap use case mengenkapsulasi satu operasi bisnis dan memanggil repository yang sesuai.

| Use Case | Deskripsi | Repository |
|----------|-----------|------------|
| `ValidateGPSUseCase` | Validasi lokasi GPS (cek permission, service, geofence) | `LocationRepository` |
| `ClockInUseCase` | Clock-in dengan validasi GPS + cek duplikat | `AttendanceRepository` |
| `ClockOutUseCase` | Clock-out dengan validasi GPS | `AttendanceRepository` |
| `GetWeeklyStatsUseCase` | Statistik kehadiran mingguan | `AttendanceRepository` |
| `GetAttendanceHistoryUseCase` | Riwayat kehadiran per bulan | `AttendanceRepository` |
| `UpdateProfileUseCase` | Update profil (validasi nama ≥ 3 char, format HP) | `UserRepository` |
| `ChangePasswordUseCase` | Ubah password (validasi ≥ 6 char, konfirmasi) | `UserRepository` |
| `SignInWithNikUseCase` | Login dengan NIK/email + password | `AuthRepository` |
| `RegisterEmployeeUseCase` | Registrasi karyawan baru | `AuthRepository` |
| `SendPasswordResetUseCase` | Kirim email reset password | `AuthRepository` |
| `SignOutUseCase` | Logout | `AuthRepository` |
| `ObserveAuthStateUseCase` | Stream status autentikasi | `AuthRepository` |
| `SubmitLeaveUseCase` | Ajukan izin/cuti (validasi tanggal & alasan) | `LeaveRepository` |
| `GetMyLeavesUseCase` | Ambil riwayat izin sendiri | `LeaveRepository` |
| `GetPendingLeavesUseCase` | Ambil izin pending (Admin) | `LeaveRepository` |
| `GetAllLeavesUseCase` | Ambil semua izin (Admin) | `LeaveRepository` |
| `ReviewLeaveUseCase` | Setujui/tolak izin (Admin) | `LeaveRepository` |

---

## 7. Error Handling

### AppResult Pattern

Semua operasi repository mengembalikan `AppResult<T>` — sealed class yang mewakili sukses atau gagal:

```dart
sealed class AppResult<T> {
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  });
}

class AppSuccess<T> extends AppResult<T> { final T value; }
class AppFailure<T> extends AppResult<T> { final Failure error; }
```

### Failure Types

| Tipe | Deskripsi |
|------|-----------|
| `AuthFailure` | Error autentikasi (login gagal, password salah, dll) |
| `DataFailure` | Error akses data Firestore |
| `NetworkFailure` | Error jaringan/koneksi |
| `GPSFailure` | Error terkait GPS/lokasi |
| `AttendanceFailure` | Error terkait kehadiran |
| `UnknownFailure` | Error tidak terduga |

Setiap `Failure` memiliki:
- `message: String` — pesan error yang bisa ditampilkan ke user
- `code: String?` — kode error opsional untuk debugging

---

## 8. Konfigurasi & Konstanta

### App Constants

```dart
class AppConstants {
  // Identitas Aplikasi
  static const String appName    = 'Absen!';
  static const String appTagline = 'Factory attendance, safer and smarter.';

  // Firebase
  static const String firebaseProjectId = 'hsil-attendance';
  static const String nikEmailDomain    = 'hsil.factory';

  // Lokasi Kantor (Geofence)
  static const String officeName         = 'Telkom University';
  static const double officeLatitude     = -6.973007;
  static const double officeLongitude    = 107.630713;
  static const double officeRadiusMeters = 500;

  // Timing
  static const Duration splashDuration = Duration(milliseconds: 1500);
  static const int maxRetryAttempts    = 3;

  // Kehadiran
  static const String defaultShiftStart    = '08:00';
  static const int    lateThresholdMinutes = 15;   // Telat jika > 15 menit
  static const int    gpsDistanceFilter    = 10;   // Meters (stream update interval)
}
```

---

## 9. Routing / Navigasi

### Route Constants

| Route Name | Path | Deskripsi |
|------------|------|-----------|
| `splash` | `/` | Splash screen |
| `login` | `/login` | Halaman login |
| `register` | `/register` | Halaman registrasi |
| `forgotPassword` | `/forgot-password` | Halaman lupa password |
| `dashboard` | `/dashboard` | Dashboard utama |
| `gpsValidation` | `/gps-validation` | Validasi GPS & absen |
| `attendanceDetail` | `/attendance-detail` | Detail kehadiran |
| `editProfile` | `/edit-profile` | Edit profil |
| `changePassword` | `/change-password` | Ubah password |
| `notifications` | `/notifications` | Notifikasi |
| `leaveRequest` | `/leave-request` | Pengajuan izin |

### Admin Routes

| Route Name | Path | Deskripsi |
|------------|------|-----------|
| `adminDashboard` | `/admin-dashboard` | Dashboard admin |
| `employeeList` | `/admin-employee-list` | Daftar karyawan |
| `employeeDetail` | `/admin-employee-detail` | Detail karyawan |
| `adminMap` | `/admin-map` | Peta live tracking |
| `kpiDashboard` | `/admin-kpi-dashboard` | Grafik KPI |
| `adminAttendanceLog` | `/admin-attendance-log` | Log kehadiran |
| `leaveApproval` | `/admin-leave-approval` | Persetujuan izin |
| `leaveHistory` | `/admin-leave-history` | Riwayat perizinan |
| `adminAddEmployee` | `/admin/add-employee` | Tambah karyawan |
| `adminBroadcast` | `/admin/broadcast` | Pengumuman massal |

---

> **Dokumen ini dibuat secara otomatis berdasarkan analisis codebase HSIL Attendance System.**  
> **Terakhir diperbarui**: Juni 2026
