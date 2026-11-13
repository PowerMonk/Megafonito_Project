# 📢 Megafonito - School Announcements App

A simple school announcements/notices app that makes communication easier between students, teachers, and staff.

## 🛠️ Tech Stack

- **Frontend**: Flutter (Android focused)
- **Demo backend**: Bun + SQLite + WebSocket (`server/`)
- **Demo landing**: Astro (`server/web/`)
- **Legacy backend**: Deno + Oak + PostgreSQL (`backend/`, not used by the demo)
- **Demo authentication**: opaque session tokens, no JWT
- **Cloud services**: none for the demo

## Demo local (Bun + SQLite)

Esta es la ruta pensada para la presentación académica: sin Supabase, sin
Firebase, sin Docker y sin internet.

```bash
cd server
bun install
bun run start
```

Abre `http://localhost:8787` en la laptop. La landing muestra las URLs LAN, los
QR para conectar la tablet y el teléfono, las cuentas demo y un botón para
reiniciar los datos.

Cuentas:

| Usuario | Contraseña | Rol |
| --- | --- | --- |
| `admin` | `admin123` | administrador |
| `student1` | `1234` | alumno de Sistemas |
| `student2` | `1234` | alumno de Mecánica |

Guía completa: [`server/README.md`](server/README.md) y
[`docs/demo-day.md`](docs/demo-day.md).

## 🚀 Legacy backend quick start (not used by the demo)

> The commands below belong to the old Deno + PostgreSQL backend. For the
> academic demo use the `server/` folder above.

### Prerequisites
- [Flutter](https://flutter.dev/docs/get-started/install) installed
- [Deno](https://deno.com/manual/getting_started/installation) installed
- [PostgreSQL](https://www.postgresql.org/download/) running
- [Docker](https://www.docker.com/get-started/) (optional)

### Option 1: Run with Docker (Easiest)
```bash
# Clone the repository
git clone <your-repo-url>
cd Megafonito

# Start everything with Docker
docker-compose up
```
The API will be available at `http://localhost:8000`

### Option 2: Run Manually

#### Backend Setup
```bash
# Navigate to backend folder
cd backend

# Run the API server
deno task server
```

#### Frontend Setup
```bash
# Navigate to frontend folder
cd frontend

# Install dependencies and run
flutter pub get
flutter run
```

## 📱 Features

- **User Management**: Create, update, and manage user accounts
- **Role-Based Access**: Admin, Teacher, and Student roles
- **Notices System**: Create, view, and manage school announcements
- **File Upload**: Upload and manage files with AWS S3
- **Authentication**: Secure JWT-based login system

## 🔧 API Endpoints

- `GET /healthy` - Health check
- `POST /login` - User login
- `POST /users` - Create user (Admin only)
- `GET /users` - Get all users (Admin only)
- `POST /notices` - Create notice
- `GET /notices` - Get user's notices
- `GET /allnotices` - Get all notices
- `POST /upload/s3` - Upload files

## 🤝 Contributing

We welcome contributions! Here's how:

**Frontend**: Submit UI designs in the `UX/UI` folder + create a pull request with clear explanations

**Backend**: Create detailed pull requests explaining how changes benefit the project's scalability

## 📝 Notes

- Android development focused (no iOS support yet)
- UI is being redesigned
- Backend uses PostgreSQL with migrations in `backend/db/migrations/`
