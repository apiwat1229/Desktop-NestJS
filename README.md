# My App - Monorepo

A modern desktop application monorepo built with **Nextron** (Next.js + Electron), **NestJS**, **Prisma**, and **PostgreSQL**.

## 🏗️ Architecture

```
my-app-monorepo/
├── apps/
│   ├── desktop/          # Nextron (Next.js + Electron) frontend
│   └── api/              # NestJS backend API
├── packages/
│   ├── database/         # Prisma schema and migrations
│   └── types/            # Shared TypeScript types
└── docker-compose.yml    # PostgreSQL for local development
```

## 🚀 Tech Stack

### Frontend (Desktop App)
- **Nextron**: Next.js + Electron framework
- **Next.js 14**: React framework with static export
- **Shadcn/UI**: Beautiful UI components
- **Tailwind CSS**: Utility-first CSS
- **React Query**: Data fetching and caching
- **TypeScript**: Type safety

### Backend (API)
- **NestJS**: Progressive Node.js framework
- **Prisma**: Next-generation ORM
- **PostgreSQL**: Relational database
- **JWT**: Authentication
- **Passport**: Auth middleware
- **TypeScript**: Type safety

## 📋 Prerequisites

- **Node.js**: >= 18.0.0
- **npm**: >= 9.0.0
- **Docker** (optional): For local PostgreSQL
- **PostgreSQL**: If not using Docker

## 🛠️ Getting Started

### 1. Clone and Install

```bash
cd /Users/apiwat/Desktop/My-App
npm install
```

This will install all dependencies for the monorepo and all workspaces.

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

This starts PostgreSQL on port 5432 and pgAdmin on port 5050.

**Option B: Local PostgreSQL**

Install PostgreSQL locally and create a database named `myapp`.

### 4. Database Setup

Generate Prisma Client and run migrations:

```bash
cd packages/database
npm run generate
npm run migrate
npm run seed
```

This will:
- Generate the Prisma Client
- Create database tables
- Seed with sample data (admin user, sample posts)

### 5. Start Development

From the root directory:

```bash
npm run dev
```

This starts:
- **API Server**: http://localhost:3000/api
- **Desktop App**: Electron window (Next.js on http://localhost:8888)
- **Prisma Studio**: http://localhost:5555

Or start individually:

```bash
# API only
npm run dev:api

# Desktop app only
npm run dev:desktop

# Prisma Studio only
npm run db:studio
```

## 🔑 Default Credentials

After running the seed script:

- **Email**: admin@example.com
- **Password**: (hashed in seed.ts - update with bcrypt)

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

Output will be in `apps/desktop/dist/`.

### Build API

```bash
cd apps/api
npm run build
npm run start:prod
```

Or use Docker:

```bash
cd apps/api
docker build -t myapp-api .
docker run -p 3000:3000 --env-file ../../.env myapp-api
```

## 🗂️ Project Structure

### Apps

#### `apps/desktop` - Nextron Application
```
desktop/
├── main/              # Electron main process
│   ├── background.ts  # Main window creation
│   └── preload.ts     # Context bridge
├── renderer/          # Next.js application
│   ├── pages/         # Next.js pages
│   ├── components/    # React components
│   ├── lib/           # Utilities and API client
│   └── styles/        # Global styles
└── electron-builder.yml
```

#### `apps/api` - NestJS Application
```
api/
├── src/
│   ├── auth/          # Authentication module
│   ├── users/         # Users CRUD module
│   ├── posts/         # Posts CRUD module
│   ├── prisma/        # Prisma service
│   ├── app.module.ts  # Root module
│   └── main.ts        # Entry point
└── Dockerfile
```

### Packages

#### `packages/database` - Prisma
```
database/
├── prisma/
│   ├── schema.prisma  # Database schema
│   ├── migrations/    # Migration files
│   └── seed.ts        # Seed script
└── src/
    └── index.ts       # Prisma client export
```

#### `packages/types` - Shared Types
```
types/
└── src/
    ├── api.ts         # API DTOs
    ├── models.ts      # Domain models
    └── index.ts       # Exports
```

## 🔐 Authentication

The API uses JWT-based authentication:

1. **Register/Login**: POST `/api/auth/register` or `/api/auth/login`
2. **Receive Token**: Get `accessToken` in response
3. **Use Token**: Include in `Authorization: Bearer <token>` header

Protected routes require authentication. Admin-only routes require `ADMIN` role.

## 📡 API Endpoints

### Auth
- `POST /api/auth/login` - Login
- `POST /api/auth/register` - Register

### Users (Protected)
- `GET /api/users` - List all users (Admin only)
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create user (Admin only)
- `PATCH /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user (Admin only)

### Posts
- `GET /api/posts` - List all posts (public)
- `GET /api/posts/:id` - Get post by ID
- `POST /api/posts` - Create post (Auth required)
- `PATCH /api/posts/:id` - Update post (Author/Admin)
- `DELETE /api/posts/:id` - Delete post (Author/Admin)

### Health
- `GET /api/health` - Health check

## 🗄️ Database Management

### Prisma Studio

Visual database browser:

```bash
npm run db:studio
```

Access at http://localhost:5555

### Migrations

```bash
cd packages/database

# Create migration
npm run migrate

# Deploy migrations
npm run migrate:deploy

# Reset database
npm run migrate:reset
```

### pgAdmin

If using Docker Compose, access pgAdmin at http://localhost:5050:

- **Email**: admin@admin.com
- **Password**: admin

## 🚢 Deployment

### Backend Deployment Options

**Option 1: Separate API Server (Recommended)**

Deploy the NestJS API to a cloud provider:
- Heroku, Railway, Render
- AWS (ECS, Lambda)
- DigitalOcean App Platform
- Vercel (serverless)

**Option 2: Sidecar Process**

Bundle the API with the Electron app to run locally. This requires:
1. Building the API as a standalone executable
2. Starting it from the Electron main process
3. Configuring the frontend to use `localhost` API

### Database Deployment

Use a managed PostgreSQL service:
- **AWS RDS**
- **DigitalOcean Managed Databases**
- **Supabase**
- **Heroku Postgres**
- **Railway**

Update `DATABASE_URL` in production environment.

### Desktop App Distribution

Use Electron Builder to create installers:

```bash
cd apps/desktop
npm run build:mac    # .dmg for macOS
npm run build:win    # .exe for Windows
npm run build:linux  # .AppImage for Linux
```

## 🧪 Development Tools

### Available Scripts

From root:
- `npm run dev` - Start all services
- `npm run build` - Build all workspaces
- `npm run lint` - Lint all code
- `npm run format` - Format with Prettier
- `npm run type-check` - TypeScript check
- `npm run clean` - Remove all node_modules

### VSCode Setup

Recommended extensions:
- ESLint
- Prettier
- Prisma
- Tailwind CSS IntelliSense

Settings are pre-configured in `.vscode/settings.json`.

## 📝 Adding Shadcn/UI Components

```bash
cd apps/desktop/renderer
npx shadcn-ui@latest add button
npx shadcn-ui@latest add card
npx shadcn-ui@latest add dialog
```

Components will be added to `renderer/components/ui/`.

## 🤝 Contributing

1. Create a feature branch
2. Make changes
3. Run `npm run lint` and `npm run type-check`
4. Submit a pull request

## 📄 License

MIT

## 🆘 Troubleshooting

### Database Connection Issues

- Ensure PostgreSQL is running
- Check `DATABASE_URL` in `.env`
- Verify database exists: `psql -U postgres -l`

### Prisma Client Not Found

```bash
cd packages/database
npm run generate
```

### Electron App Won't Start

- Check Next.js dev server is running on port 8888
- Clear `.next` cache: `rm -rf apps/desktop/renderer/.next`

### API 404 Errors

- Ensure API is running on port 3000
- Check `API_URL` in frontend environment
- Verify CORS settings in `apps/api/src/main.ts`

## 📚 Learn More

- [Nextron Documentation](https://github.com/saltyshiomix/nextron)
- [Next.js Documentation](https://nextjs.org/docs)
- [NestJS Documentation](https://docs.nestjs.com)
- [Prisma Documentation](https://www.prisma.io/docs)
- [Shadcn/UI Documentation](https://ui.shadcn.com)
# Desktop-NestJS
