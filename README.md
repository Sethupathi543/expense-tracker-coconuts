# 🥥 Coconut Expense Tracker

A modern, full-stack business management and expense tracking application tailored for coconut farm owners, merchants, traders, and agricultural entrepreneurs.

Built with a **Flutter** frontend (Web, Mobile, and Desktop) and a **Spring Boot 3** Java REST API backend with **MySQL** and **JWT Security**.

---

## 📌 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [System Architecture](#-system-architecture)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup](#1-backend-setup-spring-boot)
  - [Frontend Setup](#2-frontend-setup-flutter)
- [API Endpoints](#-api-endpoints)
- [Hosting & Deployment Guide](#-hosting--deployment-guide)
  - [Hosting Frontend on Vercel](#hosting-frontend-on-vercel)
  - [Hosting Backend](#hosting-the-backend)
- [Contributing & License](#-license)

---

## ✨ Features

### 1. 📊 Interactive Dashboard
- Real-time financial summary (Total Expenses, Total Earnings, Net Balance).
- Recent transaction feeds and category distribution.
- Quick navigation shortcuts to core operations.

### 2. 💸 Comprehensive Expense Management
- Categorized expense tracking:
  - 👷 **Labour**: Field work, climbers, harvesting teams
  - 🚚 **Transport**: Tractor, lorry, logistics, loading/unloading
  - 🥥 **Coconut**: Raw purchases and farm-gate acquisition
  - ⛽ **Fuel**: Diesel, petrol, and vehicle operational costs
  - 🍲 **Food**: Field worker meals, tea, refreshments
  - 🍾 **Beverages**: Miscellaneous refreshments
  - 📦 **Other**: Tools, equipment maintenance, and supplies
- Multiple payment modes: **Cash**, **UPI**, **Bank Transfer**.
- Digital receipt viewer and printing support.

### 3. 🌴 Coconut Business Module
- **Farmer Management**:
  - Maintain farmer profiles, contact records, and farm locations.
  - Track farmer transactions: batch purchases, nut count, rate per nut/ton, and payment status.
- **Trader Management**:
  - Maintain wholesale buyer and trader profiles.
  - Track trader sales: dispatches, grade classification, revenue, and outstanding dues.
- **Resource & By-Product Earnings**:
  - Record sales of secondary coconut resources (Husk/Coir, Shells, Copra, Firewood, Tender coconut water).
  - Separate revenue calculation to analyze supplemental farm earnings.

### 4. 📈 Reports & Analytics
- Filter expenses and earnings by custom date ranges (Today, This Week, This Month, Custom).
- Visual breakdown by category and transaction daily trends.
- Print and export transaction summaries and receipts.

### 5. 🔐 Security & Multi-Platform Support
- Secure authentication using **JSON Web Tokens (JWT)** and **BCrypt** password hashing.
- Role-based Spring Security filter chain.
- Responsive UI designed for Mobile (Android/iOS), Desktop, and Web browsers.
- In-app backend server URL switcher for local network or cloud deployments.

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: [Flutter](https://flutter.dev/) (Channel Stable, Dart 3)
- **Platforms Supported**: Web, Android, iOS, Windows, macOS, Linux
- **State & Networking**: `http`, `shared_preferences`, `intl`
- **UI Components**: Material 3 Design, Custom Responsive Layouts

### Backend
- **Framework**: [Spring Boot 3.3.4](https://spring.io/projects/spring-boot) (Java 21)
- **Security**: Spring Security 6 with JWT (`io.jsonwebtoken:jjwt`)
- **Persistence**: Spring Data JPA / Hibernate ORM
- **Database**: [MySQL 8.x](https://www.mysql.com/)
- **Validation**: Jakarta Validation API (`spring-boot-starter-validation`)
- **Build Tool**: Apache Maven

---

## 📐 System Architecture

```text
┌────────────────────────────────────────────────────────┐
│                   Flutter Client                       │
│    (Web Browser / Android APK / Desktop Application)   │
└───────────────────────────┬────────────────────────────┘
                            │
                     HTTP / REST (JSON)
                     Bearer JWT Tokens
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│               Spring Boot 3 Backend API                │
│  ┌──────────────────────┬────────────────────────────┐ │
│  │ WebSecurity / JWT    │ REST Controllers           │ │
│  ├──────────────────────┼────────────────────────────┤ │
│  │ Service Business     │ JPA Repositories           │ │
│  │ Logic Layer          │ & Entity Models            │ │
│  └──────────────────────┴────────────────────────────┘ │
└───────────────────────────┬────────────────────────────┘
                            │
                           JDBC
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│                   MySQL Database                       │
│              (coconut_expense_db)                      │
└────────────────────────────────────────────────────────┘
```

---

## 📂 Project Structure

```text
Basic-expense-tracker/
├── backend/                             # Spring Boot Java Backend
│   ├── src/main/java/com/example/coconutexpense/
│   │   ├── controller/                  # REST API Controllers
│   │   ├── dto/                         # Request & Response Data Transfer Objects
│   │   ├── entity/                      # JPA Database Entities
│   │   ├── exception/                   # Global exception handlers
│   │   ├── repository/                  # Spring Data JPA Repositories
│   │   ├── security/                    # JWT token filters, config & auth providers
│   │   └── service/                     # Business logic services
│   ├── src/main/resources/
│   │   └── application.properties       # DB connection, port, and JWT secrets
│   ├── pom.xml                          # Maven build dependencies
│   ├── mvnw / mvnw.cmd                  # Maven wrapper executables
│   └── run-backend.bat                  # One-click startup script
│
├── frontend/                            # Flutter Client Application
│   ├── lib/
│   │   ├── models/                      # Dart data models (Expense, Farmer, Trader, etc.)
│   │   ├── screens/                     # UI screens (Dashboard, Expenses, Farmers, Reports)
│   │   │   ├── coconut/                 # Coconut business sub-screens
│   │   │   │   ├── farmer/              # Farmer list, detail, and transaction screens
│   │   │   │   └── trader/              # Trader list, detail, and transaction screens
│   │   ├── services/                    # HTTP API and Authentication services
│   │   ├── utils/                       # Constants, colors, categories, validators
│   │   ├── widgets/                     # Reusable UI widgets & cards
│   │   └── main.dart                    # Flutter entry point
│   ├── web/                             # Web assets (index.html, icons, manifest)
│   ├── pubspec.yaml                     # Flutter package dependencies
│   └── build.sh                         # Web build script
│
├── vercel.json                          # Vercel deployment configuration & SPA routing
├── build.sh                             # CI/CD Flutter build script for web hosting
└── README.md                            # Project documentation
```

---

## 🚀 Getting Started

### Prerequisites

Ensure you have installed:
- [Java Development Kit (JDK) 21](https://adoptium.net/)
- [Apache Maven](https://maven.apache.org/) (or use the included `mvnw`)
- [MySQL Server 8.x](https://dev.mysql.com/downloads/installer/)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.22+ recommended)

---

### 1. Backend Setup (Spring Boot)

1. **Start MySQL Server** and create the database:
   ```sql
   CREATE DATABASE IF NOT EXISTS coconut_expense_db;
   ```

2. **Configure Database Credentials**:
   Open `backend/src/main/resources/application.properties` and verify your credentials:
   ```properties
   spring.datasource.url=jdbc:mysql://127.0.0.1:3306/coconut_expense_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata&createDatabaseIfNotExist=true
   spring.datasource.username=YOUR_MYSQL_USERNAME
   spring.datasource.password=YOUR_MYSQL_PASSWORD
   server.port=8080
   ```

3. **Run the Backend**:
   - On Windows:
     ```cmd
     cd backend
     run-backend.bat
     ```
   - Or using Maven Wrapper:
     ```bash
     cd backend
     ./mvnw spring-boot:run
     ```
   The backend API will start on `http://localhost:8080`.

---

### 2. Frontend Setup (Flutter)

1. **Navigate to the frontend directory**:
   ```bash
   cd frontend
   ```

2. **Install Flutter Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the Application**:
   - **For Web (Chrome)**:
     ```bash
     flutter run -d chrome
     ```
   - **For Android** (with an emulator or USB connected phone):
     ```bash
     flutter run -d android
     ```
   - **For Windows Desktop**:
     ```bash
     flutter run -d windows
     ```

> **Tip for Mobile / Remote Testing**:
> On the Login screen, click the **Settings ⚙️** icon in the top right corner to customize the Backend Server URL (e.g. `http://192.168.1.X:8080/api` or your deployed cloud backend URL).

---

## 📡 API Endpoints

All protected endpoints require an `Authorization: Bearer <TOKEN>` header.

| Module | Method | Endpoint | Description |
| :--- | :--- | :--- | :--- |
| **Auth** | `POST` | `/api/auth/register` | Register a new user account |
| **Auth** | `POST` | `/api/auth/login` | Login and receive a JWT token |
| **Dashboard**| `GET` | `/api/dashboard/summary` | Retrieve overview statistics and recent transactions |
| **Expenses** | `GET` | `/api/expenses` | List all user expenses (supports category & date filters) |
| **Expenses** | `POST` | `/api/expenses` | Create a new expense entry |
| **Expenses** | `PUT` | `/api/expenses/{id}` | Update an existing expense |
| **Expenses** | `DELETE`| `/api/expenses/{id}` | Delete an expense entry |
| **Farmers** | `GET` | `/api/farmers` | List all registered farmers |
| **Farmers** | `POST` | `/api/farmers` | Register a new farmer |
| **Farmers** | `POST` | `/api/farmer-transactions` | Record a batch coconut purchase from a farmer |
| **Traders** | `GET` | `/api/traders` | List all registered traders |
| **Traders** | `POST` | `/api/traders` | Register a new trader |
| **Traders** | `POST` | `/api/trader-transactions` | Record a sales transaction with a trader |
| **Resources**| `GET` | `/api/resource-earnings` | List earnings from coconut by-products |
| **Resources**| `POST` | `/api/resource-earnings` | Record new resource sales (coir, shells, copra, etc.) |
| **Reports** | `GET` | `/api/reports/summary` | Generate date-ranged financial analytics |

---

## 🌐 Hosting & Deployment Guide

### Hosting Frontend on Vercel

Vercel provides fast global CDN hosting for the Flutter Web frontend.

#### Option A: Deploy from GitHub (Automatic CI/CD)
1. Push your repository to GitHub.
2. In the [Vercel Dashboard](https://vercel.com/new), click **Add New Project** and select your GitHub repository.
3. Configure the Project Settings:
   - **Framework Preset**: `Other`
   - **Root Directory**: `frontend` (or leave at `./` with the root `vercel.json`)
   - **Build Command**: `bash build.sh`
   - **Output Directory**: `build/web` (or `frontend/build/web` if building from root)
4. Click **Deploy**. Vercel will install the Flutter SDK, build the release web app, and deploy it to a `.vercel.app` URL.

#### Option B: Deploy Pre-built Web Artifacts
If you prefer building locally:
1. Build the release bundle locally:
   ```bash
   cd frontend
   flutter build web --release
   ```
2. Deploy the `build/web` directory using the Vercel CLI:
   ```bash
   cd frontend/build/web
   npx vercel --prod
   ```

---

### Hosting the Backend

Because Spring Boot requires a persistent Java runtime and a MySQL database (which static hosts like Vercel do not execute directly), deploy the backend to any of the following platforms:

- **[Render](https://render.com/)**: Free/low-cost Web Service + Managed MySQL.
- **[Railway](https://railway.app/)**: Instant Docker or Java deployment with one-click MySQL database.
- **[Fly.io](https://fly.io/) / [Heroku](https://www.heroku.com/) / AWS EC2 / DigitalOcean Droplet**.

Once your backend is deployed to a live URL (e.g., `https://coconut-api.onrender.com`), connect your frontend by either:
1. Entering the URL in the in-app **Server Settings (⚙️)** on the Login screen.
2. Building Flutter with `--dart-define=API_URL=https://coconut-api.onrender.com/api`.
3. Configuring the proxy rewrite inside `vercel.json`.

---

## 📄 License

This project is licensed under the MIT License - feel free to use and adapt it for your farm or commercial business.
