import {initializeApp} from "firebase-admin/app";
import {FieldValue, Timestamp, getFirestore} from "firebase-admin/firestore";
import {getAuth} from "firebase-admin/auth";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as nodemailer from "nodemailer";

initializeApp();

const db = getFirestore();

// Konfigurasi Nodemailer dengan App Password
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "gilangwasis2@gmail.com",
    pass: "sujg zwoe bhyw tmxb",
  },
});

type UserRole = "employee" | "admin";

interface CreateEmployeeRequest {
  uid: string;
  nik: string;
  name: string;
  email: string;
  role: UserRole;
  department: string;
  position: string;
  phone?: string;
  shiftStart?: string;
  shiftEnd?: string;
}

async function assertAdmin(uid?: string): Promise<void> {
  if (!uid) {
    throw new HttpsError("unauthenticated", "Login dibutuhkan.");
  }
  const caller = await db.collection("users").doc(uid).get();
  if (!caller.exists || caller.get("role") !== "admin" || caller.get("isActive") !== true) {
    throw new HttpsError("permission-denied", "Hanya admin aktif yang boleh menjalankan aksi ini.");
  }
}

function validateEmployeePayload(data: CreateEmployeeRequest): void {
  if (!/^\d{10}$/.test(data.nik)) {
    throw new HttpsError("invalid-argument", "NIK harus 10 digit.");
  }
  if (!["employee", "admin"].includes(data.role)) {
    throw new HttpsError("invalid-argument", "Role tidak valid.");
  }
  if (!data.uid || !data.name || !data.email || !data.department || !data.position) {
    throw new HttpsError("invalid-argument", "Payload karyawan belum lengkap.");
  }
}

export const createEmployeeProfile = onCall<CreateEmployeeRequest>(async (request) => {
  await assertAdmin(request.auth?.uid);
  validateEmployeePayload(request.data);

  const now = FieldValue.serverTimestamp();
  await db.collection("users").doc(request.data.uid).set({
    userId: request.data.uid,
    nik: request.data.nik,
    name: request.data.name,
    email: request.data.email,
    role: request.data.role,
    department: request.data.department,
    position: request.data.position,
    phone: request.data.phone ?? null,
    photoUrl: null,
    shiftStart: request.data.shiftStart ?? "08:00",
    shiftEnd: request.data.shiftEnd ?? "17:00",
    isActive: true,
    createdAt: now,
    updatedAt: now,
  });

  return {ok: true};
});

export const createClockInNotification = onDocumentCreated("attendance/{attendanceId}", async (event) => {
  const data = event.data?.data();
  if (!data?.userId) {
    return;
  }

  await db.collection("notifications").add({
    userId: data.userId,
    type: "clock_in_success",
    title: "Clock-in tersimpan",
    body: `Absensi ${data.date} berhasil tercatat.`,
    isRead: false,
    data: {
      attendanceId: event.params.attendanceId,
      status: data.status,
    },
    createdAt: FieldValue.serverTimestamp(),
  });
});

// ----------------------------------------------------------------------
// NEW ENDPOINTS: OTP & Forgot Password Flow
// ----------------------------------------------------------------------

export const requestPasswordReset = onCall<{nik: string}>(async (request) => {
  const identity = request.data.nik?.trim();
  if (!identity) {
    throw new HttpsError("invalid-argument", "Data tidak valid.");
  }

  let snapshot;
  if (identity.includes("@")) {
    snapshot = await db.collection("users").where("email", "==", identity).limit(1).get();
  } else {
    if (identity.length !== 10) {
      throw new HttpsError("invalid-argument", "NIK tidak valid.");
    }
    snapshot = await db.collection("users").where("nik", "==", identity).limit(1).get();
  }

  if (snapshot.empty) {
    throw new HttpsError("not-found", "Karyawan tidak ditemukan.");
  }

  const userDoc = snapshot.docs[0];
  const userData = userDoc.data();
  const email = userData.email;
  
  if (!email || !email.includes("@")) {
    throw new HttpsError("failed-precondition", "Karyawan belum memiliki email aktif.");
  }

  // Generate 6 digit OTP
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  
  const expiresAt = new Date();
  expiresAt.setMinutes(expiresAt.getMinutes() + 15);
  
  const userNik = userData.nik;
  
  await db.collection("passwordResets").doc(userNik).set({
    otp,
    expiresAt: Timestamp.fromDate(expiresAt),
    attempts: 0
  });

  try {
    await transporter.sendMail({
      from: '"HSIL System" <gilangwasis2@gmail.com>',
      to: email,
      subject: "Reset Password - Kode OTP",
      text: `Kode OTP Anda adalah: ${otp}\nBerlaku selama 15 menit. Jangan berikan kode ini kepada siapapun.`
    });
    
    // Return email hint
    const [namePart, domain] = email.split("@");
    const hint = namePart.substring(0, 2) + "*".repeat(namePart.length - 2) + "@" + domain;
    return { ok: true, emailHint: hint, resolvedNik: userNik };
  } catch (error) {
    console.error("Error sending email:", error);
    throw new HttpsError("internal", "Gagal mengirim email OTP.");
  }
});

export const verifyOtpAndResetPassword = onCall<{nik: string, otp: string, newPassword: string}>(async (request) => {
  const { nik, otp, newPassword } = request.data;
  if (!nik || !otp || !newPassword) {
    throw new HttpsError("invalid-argument", "Data tidak lengkap.");
  }

  const resetDocRef = db.collection("passwordResets").doc(nik);
  const resetDoc = await resetDocRef.get();
  
  if (!resetDoc.exists) {
    throw new HttpsError("not-found", "Kode OTP tidak valid atau sudah kadaluarsa.");
  }

  const data = resetDoc.data()!;
  
  if (data.attempts >= 3) {
    await resetDocRef.delete();
    throw new HttpsError("resource-exhausted", "Terlalu banyak percobaan yang salah. Silakan minta OTP baru.");
  }

  if (data.expiresAt.toDate() < new Date()) {
    await resetDocRef.delete();
    throw new HttpsError("failed-precondition", "Kode OTP sudah kadaluarsa.");
  }

  if (data.otp !== otp.trim()) {
    await resetDocRef.update({ attempts: FieldValue.increment(1) });
    throw new HttpsError("invalid-argument", "Kode OTP salah.");
  }

  const snapshot = await db.collection("users").where("nik", "==", nik).limit(1).get();
  if (snapshot.empty) {
    throw new HttpsError("not-found", "Karyawan tidak ditemukan.");
  }

  const userId = snapshot.docs[0].id;

  try {
    await getAuth().updateUser(userId, {
      password: newPassword
    });
  } catch (error) {
    console.error("Error updating password:", error);
    throw new HttpsError("internal", "Gagal mengubah password.");
  }

  await resetDocRef.delete();
  return { ok: true };
});
