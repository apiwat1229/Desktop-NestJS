# YTRC Portal - Monorepo

A modern desktop application monorepo built with **Electron + Vue 3**, **NestJS**, **Prisma**, and **PostgreSQL**.

The application is designed for the **YTRC Portal Center**, providing a robust system for managing factory operations, including user management, suppliers, bookings, and truck scale operations.

## 🏗️ Architecture

```
my-app-monorepo/
├── apps/
│   ├── desktop/          # Electron + Vue 3 + Vite frontend
│   └── api/              # NestJS backend API
├── packages/
│   ├── database/         # Prisma schema and migrations
│   └── types/            # Shared TypeScript types
└── docker-compose.yml    # PostgreSQL for local development
```

## 🚀 Key Features

### Frontend (Desktop App)

- **Electron + Vue 3**: High-performance desktop experience.
- **Layout System**:
  - **Sidebar**: Admin-only navigation for managing modules.
  - **Navbar**: Context-aware top bar with navigation controls (Back, Forward, Refresh, Home).
  - **Global Background**: Consistent animated background across all pages.
- **Dynamic Routing**: Role-based access control (Admin vs User).
- **Authentication**:
  - Secure Login with "Remember Me".
  - **Force Change Password**: New users must change their password on first login.
- **Error Handling**: Custom 404 and Error pages.
- **UI Components**: Built with **Shadcn-Vue** (Radix Vue + Tailwind CSS) and **Lucide Icons**.

### Backend (API)

- **NestJS**: Scalable server-side application.
- **Prisma ORM**: Type-safe database access with PostgreSQL.
- **Role-Based Access Control (RBAC)**: Secure endpoints based on User roles.
- **User Management**: Creating users, password reset flows, and profile management.
- **Swagger Documentation**: API endpoints documented automatically.

## 📋 Prerequisites

- **Node.js**: >= 20.0.0
- **npm**: >= 10.0.0
- **Docker** (optional): For local PostgreSQL
- **PostgreSQL**: If not using Docker

## 🛠️ Getting Started

### 1. Clone and Install

```bash
cd /path/to/project
npm install
```

### 2. Environment Setup

Copy the environment template:

```bash
cp .env.example .env
```

Edit `.env` and configure your database connection:

```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/myapp?schema=public"
API_URL="http://localhost:3000"
JWT_SECRET="your-secret-key-change-in-production"
```

### 3. Start PostgreSQL

**Option A: Using Docker (Recommended)**

```bash
npm run dev:db
# or
docker-compose up -d
```

**Option B: Local PostgreSQL**

Install PostgreSQL locally and create a database named `myapp`.

### 4. Database Setup

Generate Prisma Client and run migrations:

```bash
cd packages/database
npx prisma generate
npx prisma migrate dev
npx prisma db seed
```

This will:

- Generate the Prisma Client
- Create database tables
- Seed with sample data

### 5. Start Development

**Quick Start (Recommended for Web Development):**

```bash
npm run dev:web
```

This starts both API server and Vite dev server for browser-based development.

**Available Development Commands:**

| Command               | Description           | Use Case                                   |
| --------------------- | --------------------- | ------------------------------------------ |
| `npm run dev:web`     | API + Vite (web mode) | 🌐 **Recommended** for browser development |
| `npm run dev`         | API + Electron        | 🖥️ Desktop app development                 |
| `npm run dev:api`     | API server only       | 🔧 Backend development                     |
| `npm run dev:vite`    | Vite dev server only  | 🎨 Frontend development                    |
| `npm run dev:desktop` | Electron app only     | ⚡ Desktop app testing                     |
| `npm run dev:db`      | PostgreSQL (Docker)   | 🗄️ Start database                          |

**Access Points:**

- **Web App**: http://localhost:5173/
- **API Server**: http://localhost:2530/api
- **API Docs (Swagger)**: http://localhost:2530/api/docs

**Development Workflow:**

1. **For Web Development** (Most Common):

   ```bash
   npm run dev:web
   ```

   Then open http://localhost:5173/ in your browser.

2. **For Desktop App Development**:

   ```bash
   npm run dev
   ```

   Electron window will open automatically.

3. **For Backend Only**:
   ```bash
   npm run dev:api
   ```

## 🔐 Credentials & Authentication

**Default Admin Account:**

- Username: `apiwat.s`
- Password: `Copterida@1229`
- Role: Admin

**Test Accounts:**

- Email: `admin@example.com`
- Password: `password` (You will be forced to change this on first login)

**Authentication Features:**

- ✅ JWT-based authentication
- ✅ Role-based access control (Admin, User)
- ✅ Force password change on first login
- ✅ Remember me functionality
- ✅ Account locking after failed attempts
- ✅ Password reset flow

## 📦 Building for Production

### Build Desktop App

```bash
cd apps/desktop

# Build for current platform
npm run build

# Build for specific platforms
npm run build:mac
npm run build:win
npm run build:linux
```

Output will be in `dist/`.

### Build API

```bash
cd apps/api
npm run build
npm run start:prod
```

## 🗂️ Project Structure

### Apps

#### `apps/desktop` - Frontend

- `src/main/`: Electron main process.
- `src/preload/`: Context bridge.
- `src/renderer/`: Vue 3 application.
  - `components/layout/`: Sidebar, Navbar, MainLayout, GlobalBackground.
  - `views/`: Page components (Login, Home, TruckScale, NotFound, Error).
  - `stores/`: Pinia state management (Auth).

#### `apps/api` - Backend

- `src/auth/`: Authentication logic (Login, Change Password, Guards).
- `src/users/`: User management.
- `src/bookings/`: Booking management for truck scale.
- `src/app.module.ts`: Root module.

### Packages

#### `packages/database`

- `prisma/schema.prisma`: Database schema definition.

## 🛠️ Useful Commands

### Database Management

```bash
# Open Prisma Studio (Database GUI)
npm run db:studio

# Generate Prisma Client
cd packages/database && npx prisma generate

# Create new migration
cd packages/database && npx prisma migrate dev --name your_migration_name

# Reset database (⚠️ Deletes all data)
cd packages/database && npx prisma migrate reset
```

### Code Quality

```bash
# Run linter
npm run lint

# Format code
npm run format

# Type checking
npm run type-check
```

### Cleaning

```bash
# Remove all node_modules
npm run clean

# Then reinstall
npm install
```

## 🐛 Troubleshooting

### Port Already in Use

If you see `EADDRINUSE` error:

```bash
# Kill process on port 2530 (API)
lsof -ti :2530 | xargs kill -9

# Kill process on port 5173 (Vite)
lsof -ti :5173 | xargs kill -9

# Or kill both
lsof -ti :2530 -ti :5173 | xargs kill -9
```

### Vite Server Not Starting

If `npm run dev` doesn't start the web server:

```bash
# Use web mode instead
npm run dev:web
```

### Database Connection Issues

1. Check if PostgreSQL is running:

   ```bash
   docker ps  # if using Docker
   ```

2. Verify DATABASE_URL in `.env`

3. Regenerate Prisma Client:
   ```bash
   cd packages/database && npx prisma generate
   ```

## 🤝 Contributing

1. Create a feature branch
2. Make changes
3. Run `npm run lint`
4. Submit a pull request

## 📄 License

MIT
