import {initializeApp} from "firebase-admin/app";
import {FieldValue, getFirestore} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {onDocumentCreated} from "firebase-functions/v2/firestore";

initializeApp();

const db = getFirestore();

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
