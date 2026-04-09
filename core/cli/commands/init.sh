#!/bin/bash

import "@/utils/log"
import "@/utils/colors"

LOG_FILE="$CORE_CACHE/init_project.log"

init_help() {
	echo
	box "Core Project Initializer"
	echo
	log_info "Usage: core init <template>"
	echo
	log_info "Run this inside an existing project to configure it."
	echo
	separator_section "Available Templates"
	echo
	printf "    ${D_CYAN}%-12s${NC} %s\n" "next" "Configure Next.js project"
	printf "    ${D_CYAN}%-12s${NC} %s\n" "react" "Configure React + Vite project"
	printf "    ${D_CYAN}%-12s${NC} %s\n" "nest" "Configure NestJS project"
	printf "    ${D_CYAN}%-12s${NC} %s\n" "express" "Configure Express.js API"
	echo
	separator_section "Examples"
	echo
	printf "    ${D_CYAN}cd my-next-app && core init next${NC}\n"
	printf "    ${D_CYAN}cd my-react-app && core init react${NC}\n"
	printf "    ${D_CYAN}cd api && core init express${NC}\n"
	printf "    ${D_CYAN}cd backend && core init nest${NC}\n"
	echo
}

check_project_exists() {
	if [[ ! -f "package.json" ]]; then
		log_error "No project found in current directory"
		log_info "Make sure you're inside a project directory"
		return 1
	fi
	return 0
}

# ===== NEXT.JS =====
configure_next() {
	separator
	box "Configuring Next.js Project"
	separator
	echo
	check_project_exists || return 1

	if ! grep -q "next" package.json 2>/dev/null; then
		log_warn "This doesn't appear to be a Next.js project"
		read_confirm "Continue anyway?" CONFIRM
		[[ "$CONFIRM" != "y" ]] && { log_warn "Cancelled"; return 0; }
	fi

	log_info "Installing dependencies..."
	if loading "Installing dependencies" _install_next_deps; then
		log_success "Dependencies installed"
		echo
		list_item "axios, lucide-react, framer-motion, sonner, zod"
		list_item "react-hook-form, @hookform/resolvers"
		list_item "@tanstack/react-query, zustand, tailwindcss"
		list_item "prettier, prettier-plugin-tailwindcss"
		echo
	else
		log_warn "Some dependencies failed to install"
	fi

	log_info "Setting up structure..."
	mkdir -p src/components/ui src/lib src/hooks src/types src/config src/store 2>/dev/null

	# Crear .prettierrc
	cat >.prettierrc <<'EOF'
{
  "plugins": ["prettier-plugin-tailwindcss"]
}
EOF
	log_success "Created .prettierrc"

	log_info "Creating DevCoreX landing page..."
	[[ -f "src/app/page.tsx" ]] && cat >src/app/page.tsx <<'EOF'
"use client"
import { Button } from "@/components/ui/button"
import { motion } from "framer-motion"
import { Terminal, Code2, Rocket } from "lucide-react"
import { Toaster } from "sonner"

export default function Home() {
  return (
    <main className="min-h-screen bg-gradient-to-b from-black via-slate-950 to-slate-900">
      <Toaster position="top-center" richColors />
      <div className="container mx-auto px-4 py-20">
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="text-center">
          <motion.div initial={{ scale: 0 }} animate={{ scale: 1 }} transition={{ delay: 0.2, type: "spring" }} className="mb-8 flex justify-center">
            <div className="p-4 bg-gradient-to-br from-blue-500 to-purple-600 rounded-2xl shadow-2xl">
              <Terminal className="w-16 h-16 text-white" />
            </div>
          </motion.div>
          <motion.h1 initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }} className="text-5xl md:text-7xl font-bold mb-6 bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 bg-clip-text text-transparent">
            DevCoreX
          </motion.h1>
          <motion.p initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.4 }} className="text-xl md:text-2xl text-slate-400 mb-4">
            Comunidad de Desarrollo y Tecnología
          </motion.p>
          <motion.p initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.5 }} className="text-lg text-slate-500 mb-12 max-w-2xl mx-auto">
            Este proyecto fue creado con herramientas de la comunidad DevCoreX.
          </motion.p>
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.6 }} className="grid md:grid-cols-3 gap-6 mb-12 max-w-4xl mx-auto">
            <div className="p-6 rounded-xl bg-slate-900/50 border border-slate-800"><Code2 className="w-12 h-12 text-blue-400 mb-4 mx-auto" /><h3 className="text-lg font-semibold text-white mb-2">Código de Calidad</h3></div>
            <div className="p-6 rounded-xl bg-slate-900/50 border border-slate-800"><Rocket className="w-12 h-12 text-purple-400 mb-4 mx-auto" /><h3 className="text-lg font-semibold text-white mb-2">Proyectos Reales</h3></div>
            <div className="p-6 rounded-xl bg-slate-900/50 border border-slate-800"><Terminal className="w-12 h-12 text-pink-400 mb-4 mx-auto" /><h3 className="text-lg font-semibold text-white mb-2">Comunidad Activa</h3></div>
          </motion.div>
          <motion.div initial={{ opacity: 0, scale: 0.8 }} animate={{ opacity: 1, scale: 1 }} transition={{ delay: 0.7 }} className="w-full max-w-sm mx-auto">
            <Button size="lg" onClick={() => window.open("https://youtube.com/@devcorex", "_blank")} className="w-full bg-gradient-to-r from-blue-500 to-purple-600 hover:from-blue-600 hover:to-purple-700 text-white px-8 py-6 text-lg font-semibold">
              <Rocket className="w-5 h-5 mr-2" /> Únete a DevCoreX en YouTube
            </Button>
          </motion.div>
          <motion.p initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.8 }} className="mt-16 text-sm text-slate-600">Built with ❤️ using DevCoreX tools</motion.p>
        </motion.div>
      </div>
    </main>
  )
}
EOF

	# Actualizar package.json para usar --webpack
	if [[ -f "package.json" ]]; then
		log_info "Updating package.json scripts..."
		local temp=$(mktemp)
		jq '.scripts.dev = "next dev --webpack" | .scripts.build = "next build --webpack" | .scripts.start = "next start"' package.json > "$temp" && mv "$temp" package.json
		log_success "Added --webpack flag to dev and build scripts"
	fi

	[[ -f "src/app/layout.tsx" ]] && cat >src/app/layout.tsx <<'EOF'
import type { Metadata } from "next"
import { Inter } from "next/font/google"
import "./globals.css"
const inter = Inter({ subsets: ["latin"] })
export const metadata: Metadata = {
  title: "DevCoreX - Comunidad de Desarrollo",
  description: "Únete a la comunidad DevCoreX",
}
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (<html lang="es"><body className={inter.className}>{children}</body></html>)
}
EOF

	echo
	separator
	log_success "Next.js configured!"
	separator
	echo
	list_item "Dependencies installed"
	list_item "DevCoreX landing page created"
	list_item "Prettier configured"
	echo
	log_info "Next steps:"
	echo
	list_item "Initialize shadcn: ${D_CYAN}npx shadcn@latest init${NC}"
	list_item "Add button: ${D_CYAN}npx shadcn@latest add button${NC}"
	list_item "Start: ${D_CYAN}npm run dev${NC} (with --webpack)"
	echo
}

_install_next_deps() {
	npm install axios lucide-react framer-motion sonner zod react-hook-form @hookform/resolvers @tanstack/react-query zustand tailwindcss &>"$LOG_FILE"
	npm install -D prettier prettier-plugin-tailwindcss &>>"$LOG_FILE"
}

# ===== REACT + VITE =====
configure_react() {
	separator
	box "Configuring React + Vite Project"
	separator
	echo
	check_project_exists || return 1

	if ! grep -q "vite" package.json 2>/dev/null; then
		log_warn "This doesn't appear to be a Vite project"
		read_confirm "Continue anyway?" CONFIRM
		[[ "$CONFIRM" != "y" ]] && { log_warn "Cancelled"; return 0; }
	fi

	log_info "Installing dependencies..."
	if loading "Installing dependencies" _install_react_deps; then
		log_success "Dependencies installed"
		echo
		list_item "axios, lucide-react, framer-motion, sonner, zod"
		list_item "react-hook-form, @hookform/resolvers"
		list_item "@tanstack/react-query, zustand, tailwindcss"
		list_item "prettier, prettier-plugin-tailwindcss"
		echo
	else
		log_warn "Some dependencies failed to install"
	fi

	log_info "Setting up structure..."
	mkdir -p src/components/ui src/lib src/hooks src/types src/config src/store src/pages 2>/dev/null

	# Crear .prettierrc
	cat >.prettierrc <<'EOF'
{
  "plugins": ["prettier-plugin-tailwindcss"]
}
EOF
	log_success "Created .prettierrc"

	log_info "Creating DevCoreX landing page..."
	if [[ -f "src/App.tsx" ]]; then
		cat >src/App.tsx <<'EOF'
import { Button } from "./components/ui/Button"
import { motion } from "framer-motion"
import { Terminal, Code2, Rocket } from "lucide-react"
import { Toaster } from "sonner"

function App() {
  return (
    <main className="min-h-screen bg-gradient-to-b from-black via-slate-950 to-slate-900">
      <Toaster position="top-center" richColors />
      <div className="container mx-auto px-4 py-20">
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="text-center">
          <motion.div initial={{ scale: 0 }} animate={{ scale: 1 }} transition={{ delay: 0.2, type: "spring" }} className="mb-8 flex justify-center">
            <div className="p-4 bg-gradient-to-br from-blue-500 to-purple-600 rounded-2xl shadow-2xl">
              <Terminal className="w-16 h-16 text-white" />
            </div>
          </motion.div>
          <motion.h1 initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }} className="text-5xl md:text-7xl font-bold mb-6 bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 bg-clip-text text-transparent">DevCoreX</motion.h1>
          <motion.p initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.4 }} className="text-xl md:text-2xl text-slate-400 mb-4">Comunidad de Desarrollo y Tecnología</motion.p>
          <motion.p initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.5 }} className="text-lg text-slate-500 mb-12 max-w-2xl mx-auto">Este proyecto fue creado con herramientas de la comunidad DevCoreX.</motion.p>
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.6 }} className="grid md:grid-cols-3 gap-6 mb-12 max-w-4xl mx-auto">
            <div className="p-6 rounded-xl bg-slate-900/50 border border-slate-800"><Code2 className="w-12 h-12 text-blue-400 mb-4 mx-auto" /><h3 className="text-lg font-semibold text-white mb-2">Código de Calidad</h3></div>
            <div className="p-6 rounded-xl bg-slate-900/50 border border-slate-800"><Rocket className="w-12 h-12 text-purple-400 mb-4 mx-auto" /><h3 className="text-lg font-semibold text-white mb-2">Proyectos Reales</h3></div>
            <div className="p-6 rounded-xl bg-slate-900/50 border border-slate-800"><Terminal className="w-12 h-12 text-pink-400 mb-4 mx-auto" /><h3 className="text-lg font-semibold text-white mb-2">Comunidad Activa</h3></div>
          </motion.div>
          <motion.div initial={{ opacity: 0, scale: 0.8 }} animate={{ opacity: 1, scale: 1 }} transition={{ delay: 0.7 }} className="w-full max-w-sm mx-auto">
            <Button size="lg" onClick={() => window.open("https://youtube.com/@devcorex", "_blank")} className="w-full bg-gradient-to-r from-blue-500 to-purple-600 text-white px-8 py-6 text-lg">
              <Rocket className="w-5 h-5 mr-2" /> Únete a DevCoreX en YouTube
            </Button>
          </motion.div>
          <motion.p initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.8 }} className="mt-16 text-sm text-slate-600">Built with ❤️ using DevCoreX tools</motion.p>
        </motion.div>
      </div>
    </main>
  )
}
export default App
EOF
		log_success "Created landing page"
	fi

	if [[ ! -f "src/components/ui/Button.tsx" ]]; then
		mkdir -p src/components/ui
		cat >src/components/ui/Button.tsx <<'EOF'
import { ButtonHTMLAttributes, forwardRef } from 'react'
import { clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'
function cn(...inputs: any[]) { return twMerge(clsx(inputs)) }
interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'default' | 'outline' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
}
export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = 'default', size = 'md', children, ...props }, ref) => {
    return (
      <button className={cn('inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50',
        { 'bg-primary text-primary-foreground hover:bg-primary/90': variant === 'default',
          'border border-input hover:bg-accent hover:text-accent-foreground': variant === 'outline',
          'hover:bg-accent hover:text-accent-foreground': variant === 'ghost',
          'h-9 px-3 text-sm': size === 'sm', 'h-10 px-4': size === 'md', 'h-11 px-8': size === 'lg' },
        className)} ref={ref} {...props}>{children}</button>
    )
  }
)
Button.displayName = 'Button'
EOF
		log_success "Created Button component"
	fi

	echo
	separator
	log_success "React + Vite configured!"
	separator
	echo
	list_item "Dependencies installed"
	list_item "Prettier configured"
	echo
	list_item "Start: ${D_CYAN}npm run dev${NC}"
	echo
}

_install_react_deps() {
	npm install axios lucide-react framer-motion sonner zod react-hook-form @hookform/resolvers @tanstack/react-query zustand tailwindcss &>"$LOG_FILE"
	npm install -D prettier prettier-plugin-tailwindcss &>>"$LOG_FILE"
}

# ===== EXPRESS.JS =====
configure_express() {
	separator
	box "Configuring Express.js Project"
	separator
	echo
	check_project_exists || return 1

	if ! grep -q "express" package.json 2>/dev/null; then
		log_warn "This doesn't appear to be an Express project"
		read_confirm "Continue anyway?" CONFIRM
		[[ "$CONFIRM" != "y" ]] && { log_warn "Cancelled"; return 0; }
	fi

	log_info "Installing dependencies..."
	if loading "Installing dependencies" _install_express_deps; then
		log_success "Dependencies installed"
		echo
		list_item "express, pg, typeorm, reflect-metadata"
		list_item "jsonwebtoken, cookie-parser, morgan, cors"
		list_item "bcryptjs, helmet, cloudinary, multer"
		list_item "express-rate-limit, zod"
		echo
	else
		log_warn "Some dependencies failed to install"
	fi

	log_info "Installing devDependencies..."
	if loading "Installing devDependencies" _install_express_dev; then
		log_success "devDependencies installed"
		echo
		list_item "typescript, ts-node-dev, tsconfig-paths, tsc-alias"
		list_item "@types/* (all type definitions)"
		echo
	else
		log_warn "Some devDependencies failed to install"
	fi

	log_info "Creating folder structure..."
	_setup_express_structure

	log_info "Creating configuration files..."
	_create_express_config

	echo
	separator
	log_success "Express.js configured!"
	separator
	echo
	list_item "Start: ${D_CYAN}npm run dev${NC}"
	list_item "Build: ${D_CYAN}npm run build${NC}"
	list_item "Migrations: ${D_CYAN}npm run mg:run${NC}"
	echo
}

_install_express_deps() {
	npm install express pg typeorm reflect-metadata jsonwebtoken cookie-parser morgan cors bcryptjs helmet cloudinary multer express-rate-limit tsconfig-paths zod &>"$LOG_FILE"
}

_install_express_dev() {
	npm install -D typescript ts-node-dev tsconfig-paths tsc-alias @types/node @types/multer @types/morgan @types/jsonwebtoken @types/helmet @types/express @types/cors @types/cookie-parser @types/bcryptjs &>>"$LOG_FILE"
}

_setup_express_structure() {
	mkdir -p src/controllers 2>/dev/null
	mkdir -p src/middlewares 2>/dev/null
	mkdir -p src/repositories 2>/dev/null
	mkdir -p src/routes 2>/dev/null
	mkdir -p src/schemas 2>/dev/null
	mkdir -p src/services 2>/dev/null
	mkdir -p src/types 2>/dev/null
	mkdir -p src/utils 2>/dev/null
	mkdir -p src/config 2>/dev/null
	mkdir -p src/database/migrations 2>/dev/null
	mkdir -p src/database/seeds 2>/dev/null
	mkdir -p src/entities 2>/dev/null
	log_success "Created folder structure"
}

_create_express_config() {
	cat >tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node",
    "baseUrl": ".",
    "paths": { "@/*": ["src/*"] },
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "strictPropertyInitialization": false
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF
	log_success "Created tsconfig.json"

	cat >.env.example <<'EOF'
NODE_ENV=development
PORT=4000
DB_NAME=postgres
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
JWT_SECRET=your-super-secret-jwt-key
FRONTEND_URL=http://localhost:3000
CLOUDINARY_URL=cloudinary://API_KEY:API_SECRET@CLOUD_NAME
EOF
	log_success "Created .env.example"

	cat >src/config/env.ts <<'EOF'
export const NODE_ENV = process.env.NODE_ENV || "development";
export const PORT = Number(process.env.PORT) || 4000;
export const DB_NAME = process.env.DB_NAME || "postgres";
export const DATABASE_URL = process.env.DATABASE_URL;
export const JWT_SECRET = process.env.JWT_SECRET as string;
export const FRONTEND_URL = (process.env.FRONTEND_URL as string) || "http://localhost:3000";
EOF
	log_success "Created src/config/env.ts"

	cat >src/database/data-source.ts <<'EOF'
import "reflect-metadata";
import { DataSource } from "typeorm";
import { DATABASE_URL, NODE_ENV } from "@/config/env";
import { ExampleEntity1 } from "@/entities/ExampleEntity1";
import { ExampleEntity2 } from "@/entities/ExampleEntity2";

const isDevelopment = NODE_ENV === "development";
const isProduction = NODE_ENV === "production";

export const AppDataSource = new DataSource({
  type: "postgres",
  url: DATABASE_URL,
  ssl: isDevelopment ? false : { rejectUnauthorized: false },
  synchronize: isDevelopment,
  logging: isDevelopment ? ["query", "error"] : false,
  entities: [ExampleEntity1, ExampleEntity2],
  migrations: isDevelopment
    ? [__dirname + "/migrations/*.ts"]
    : [__dirname + "/migrations/*.js"],
  migrationsRun: isDevelopment,
  extra: {
    max: isProduction ? 10 : 20,
  },
});
EOF
	log_success "Created src/database/data-source.ts"

	cat >src/app.ts <<'EOF'
import express from "express";
import rateLimit from "express-rate-limit";
import helmet from "helmet";
import morgan from "morgan";
import cors from "cors";
import cookieParser from "cookie-parser";
import { FRONTEND_URL } from "@/config/env";
import exampleRoutes1 from "@/routes/example1.routes";
import exampleRoutes2 from "@/routes/example2.routes";

const app = express();

// monitorear peticiones HTTP (logger)
app.use(morgan("dev"));

// proteger cabeceras HTTP (seguridad)
app.use(helmet());

// habilitar acceso desde otros orígenes
app.use(
  cors({
    origin: FRONTEND_URL,
    credentials: true,
  }),
);

// limitar número de peticiones
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
});
app.use(limiter);

// parsear JSON en el body
app.use(express.json());

// manejar cookies
app.use(cookieParser());

// endpoints
app.use("/api/example1", exampleRoutes1);
app.use("/api/example2", exampleRoutes2);

export default app;
EOF
	log_success "Created src/app.ts"

	cat >src/index.ts <<'EOF'
import app from "@/app";
import { DB_NAME, PORT } from "@/config/env";
import { AppDataSource } from "@/database/data-source";

async function main() {
  try {
    await AppDataSource.initialize();
    console.log(" Connected to:", DB_NAME);
    app.listen(PORT, () => {
      console.log(" http://localhost:" + PORT);
    });
  } catch (error) {
    console.error("Internal server error:", error);
  }
}

main();
EOF
	log_success "Created src/index.ts"

	# Agregar scripts al package.json
	if [[ -f "package.json" ]]; then
		log_info "Adding scripts to package.json..."
		local temp=$(mktemp)
		jq '.scripts += {
      "dev": "ts-node-dev --require tsconfig-paths/register --env-file=.env --respawn src/index.ts",
      "build": "tsc && tsc-alias -p tsconfig.json",
      "start": "node dist/index.js",
      "typeorm": "ts-node-dev --require tsconfig-paths/register --env-file=.env ./node_modules/typeorm/cli.js",
      "mg:gen": "npm run typeorm -- migration:generate -d src/database/data-source.ts",
      "mg:create": "npm run typeorm -- migration:create",
      "mg:run": "npm run typeorm -- migration:run -d src/database/data-source.ts",
      "mg:revert": "npm run typeorm -- migration:revert -d src/database/data-source.ts",
      "mg:show": "npm run typeorm -- migration:show -d src/database/data-source.ts"
    }' package.json > "$temp" && mv "$temp" package.json
		log_success "Added scripts to package.json"
	fi
}

# ===== NESTJS =====
configure_nest() {
	separator
	box "Configuring NestJS Project"
	separator
	echo
	check_project_exists || return 1

	if ! grep -q "@nestjs" package.json 2>/dev/null; then
		log_warn "This doesn't appear to be a NestJS project"
		read_confirm "Continue anyway?" CONFIRM
		[[ "$CONFIRM" != "y" ]] && { log_warn "Cancelled"; return 0; }
	fi

	log_info "Installing NestJS dependencies..."
	if loading "Installing dependencies" _install_nest_deps; then
		log_success "Dependencies installed"
		echo
		list_item "@nestjs/typeorm, typeorm, pg"
		list_item "@nestjs/jwt, @nestjs/passport"
		list_item "class-validator, class-transformer"
		list_item "bcryptjs, helmet, cloudinary"
		echo
	else
		log_warn "Some dependencies failed to install"
	fi

	echo
	separator
	log_success "NestJS configured!"
	separator
	echo
	list_item "Start: ${D_CYAN}npm run start:dev${NC}"
	echo
}

_install_nest_deps() {
	npm install @nestjs/typeorm typeorm pg @nestjs/jwt @nestjs/passport passport passport-jwt passport-local class-validator class-transformer bcryptjs helmet cloudinary &>>"$LOG_FILE"
	npm install -D @types/passport-jwt @types/passport-local @types/bcryptjs &>>"$LOG_FILE"
}

# ===== MAIN =====
init_main() {
	local template="$1"

	case "$template" in
	next | nextjs) configure_next ;;
	react | vite) configure_react ;;
	nest | nestjs) configure_nest ;;
	express | exp) configure_express ;;
	"")
		local detected=$(detect_project_type)
		if [[ "$detected" != "unknown" ]]; then
			log_info "Detected project type: $detected"
			echo
			case "$detected" in
			next) configure_next ;;
			react) configure_react ;;
			nest) configure_nest ;;
			express) configure_express ;;
			esac
		else
			init_help
		fi
		;;
	*)
		log_error "Unknown template: $template"
		init_help
		exit 1
		;;
	esac
}

detect_project_type() {
	[[ ! -f "package.json" ]] && { echo "unknown"; return; }
	grep -q "next" package.json 2>/dev/null && { echo "next"; return; }
	grep -q "vite" package.json 2>/dev/null && { echo "react"; return; }
	grep -q "@nestjs" package.json 2>/dev/null && { echo "nest"; return; }
	grep -q "express" package.json 2>/dev/null && { echo "express"; return; }
	echo "unknown"
}
