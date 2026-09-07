# bucu_target

> Next-Generation Eye Raycasting Target Interaction System with Obsidian Glassmorphism for **BUCU Core Framework**.

Part of the **BUCU SuperApp Ecosystem** (`https://github.com/bucucore-dev/bucu_target.git`).

---

## 🌟 Fitur Utama

- **Zero-Overhead Raycasting Engine**:
  - Resmon idle **0.00ms** (hanya melakukan raycast saat tombol Left Alt ditekan).
  - Pengecekan entitas cerdas: Peds, Vehicles, Objects, dan Zones (BoxZone, SphereZone).
- **Desain Obsidian Glassmorphism**:
  - Reticle mata futuristik di tengah layar dengan animasi rotasi ganda dan cincin pulse.
  - Menu opsi interaksi melayang mulus di samping reticle dengan ikon dinamis dan shortcut angka `[1]`, `[2]`, `[3]`.
  - Efek audio feedback interaktif menggunakan Web Audio API.
- **Universal Compatibility Layer**:
  - Kompatibel 100% dengan skrip yang menggunakan sintaks **`ox_target`** (`addBoxZone`, `addSphereZone`, `addModel`, `addEntity`, `removeZone`).
  - Kompatibel 100% dengan skrip yang menggunakan sintaks **`qb-target`** (`AddBoxZone`, `AddSphereZone`, `AddTargetModel`, `AddTargetEntity`).
- **Sistem Syarat & Predikat Otomatis**:
  - Mendukung pembatasan opsi berdasarkan pekerjaan & pangkat (`job`, `minGrade`), kepemilikan item fisik di saku (`item`), dan fungsi kustom (`canInteract`).

---

## 🕹 Kontrol & Tombol

- **Left Alt (Hold / Toggle)**: Mengaktifkan mode reticle mata.
- **Klik Kanan (Right Click)**: Membuka kunci kursor mouse untuk memilih opsi secara langsung.
- **Angka 1 - 5**: Shortcut cepat untuk memilih opsi tanpa harus mengarahkan mouse.
- **Escape**: Menutup menu interaksi target.

---

## 📡 Native Exports API

```lua
-- Menambahkan Target Zone (Area Tertentu)
exports['bucu_target']:AddTargetZone('reception_desk', vector3(441.2, -980.1, 30.6), 2.0, {
    {
        name = 'open_reception',
        icon = 'id-card',
        label = 'Bicara dengan Petugas',
        event = 'bucu:client:openReception',
        distance = 2.0
    }
})

-- Menambahkan Target Model (Seluruh Objek dengan Model Hash Tertentu)
exports['bucu_target']:AddTargetModel({ 'prop_atm_01', 'prop_atm_02' }, {
    {
        name = 'access_atm',
        icon = 'credit-card',
        label = 'Gunakan Mesin ATM',
        event = 'bucu:banking:client:openATM',
        distance = 1.5
    }
})

-- Menambahkan Target Entitas Tertentu
exports['bucu_target']:AddTargetEntity(vehicleHandle, {
    {
        name = 'impound_veh',
        icon = 'shield',
        label = 'Sita Kendaraan (Polisi)',
        job = 'police',
        event = 'bucu:police:client:impoundVehicle'
    }
})
```

---

## 📦 Lisensi

Hak Cipta © 2026 Tim Pengembang BUCU Framework. Dirilis untuk ekosistem FiveM Bucu Core.
