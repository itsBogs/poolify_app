# 🏊 Poolify - Resort Cottage Reservation Application

A comprehensive mobile resort management and cottage booking application built with Flutter to streamline resort operations, cottage listings, and customer reservation tracking.

## 📸 App Preview
![Front Page](https://github.com/itsBogs/poolify_app/blob/ac4232c93249b747f6405a8168a641e4caa00162/android/poolify.png)


### User Experience
| Home Screen | Cottage Discovery | User Profile |


### Admin & Management Panels
| Admin Dashboard | Manage Reservations | Business Reports |

---

## 👥 System Roles & Features

### 1. 👤 Customer (User Side)
* **Dynamic Cottage Exploration:** Filter and browse resort cottages by category sizes (Small, Medium, Large) alongside specific feature badges like `Nature view` or capacity limits.
* **Smart Search:** Instantly look up cottages by name via the integrated search system.
* **Booking Ledger:** Monitor personal reservation dates, selected booking slots (e.g., Day Swim 8:00 AM - 5:00 PM), downpayment records, and approval tracking.
* **Profile Management:** Personalized user accounts displaying contact parameters, email logs, and a profile avatar.

### 2. 👑 Admin (Management Side)
* **Real-time Metrics Dashboard:** View critical platform operational data including Total Reservations, Cottage Counts, Registered Users, and Pending Items at a single glance.
* **User & Cottage Control:** System modules designed to fully manage registered platform users and tweak cottage availability status values (`AVAILABLE`, etc.).
* **Reservation Processing:** Evaluate incoming client requests with direct capabilities to `APPROVE` or `REJECT` reservation queues upon downpayment validation.
* **Business Analytics & Reporting:** Track comprehensive Key Performance Indicators (KPIs) such as Total Bookings, Revenue breakdowns in PHP based on approved contracts, and identify the resort's `Most Booked` asset.

---

## 🛠️ Tech Stack Used

* **Frontend Framework:** Flutter & Dart (Cross-platform UI Engine)
* **Local Database/State:** Embedded SQLite / Shared State Drivers
* **Design Guidelines:** Material Design 3 (Clean green resort theme archetype)

---

## 🚀 Installation & Local Setup

### Prerequisites
1. Download and install the [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Set up an Android Emulator or connect a physical debugging device.

### Steps
1. **Navigate into the Project Root Directory:**
```bash
   cd poolify_app
