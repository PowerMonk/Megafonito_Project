# 📢 Megafonito - School Announcements App

A simple school announcements/notices app that makes communication easier between students, teachers, and staff.

## 🛠️ Tech Stack

- **Frontend**: Flutter (Android focused)
- **Backend**: Deno + Oak framework
- **Database**: PostgreSQL
- **Authentication**: JWT tokens
- **File Storage**: AWS S3

## 🚀 Quick Start

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
