# Makefile for Impactor-2025 Docker Management
.PHONY: help build up down logs clean test dev prod

# Default target
help: ## Show this help message
	@echo "Impactor-2025 Docker Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Development Environment
dev: ## Start development environment with hot-reload
	@echo "🚀 Starting Impactor-2025 Development Environment..."
	docker compose up --build

dev-detached: ## Start development environment in background
	@echo "🚀 Starting Impactor-2025 Development Environment (detached)..."
	docker compose up -d --build

# Production Environment
prod: ## Start production environment
	@echo "🌍 Starting Impactor-2025 Production Environment..."
	docker compose -f docker compose.prod.yml up -d --build

# Container Management
build: ## Build all containers
	@echo "🔨 Building containers..."
	docker compose build

up: ## Start containers (without building)
	@echo "⬆️  Starting containers..."
	docker compose up -d

down: ## Stop and remove containers
	@echo "⬇️  Stopping containers..."
	docker compose down

restart: ## Restart all services
	@echo "🔄 Restarting services..."
	docker compose restart

# Logs and Monitoring
logs: ## View logs from all services
	docker compose logs -f

logs-backend: ## View backend logs only
	docker compose logs -f backend

logs-frontend: ## View frontend logs only
	docker compose logs -f frontend

# Development Tools
shell-backend: ## Open shell in backend container
	docker compose exec backend bash

shell-frontend: ## Open shell in frontend container
	docker compose exec frontend sh

# Database Operations
db-migrate: ## Run database migrations
	docker compose exec backend python -m alembic upgrade head

db-reset: ## Reset database
	docker compose exec backend python -m alembic downgrade base
	docker compose exec backend python -m alembic upgrade head

# Testing
test: ## Run all tests
	@echo "🧪 Running tests..."
	docker compose exec backend python -m pytest
	docker compose exec frontend npm run test

test-backend: ## Run backend tests only
	docker compose exec backend python -m pytest -v

test-frontend: ## Run frontend tests only
	docker compose exec frontend npm run test

# Maintenance
clean: ## Clean up containers, images, and volumes
	@echo "🧹 Cleaning up Docker resources..."
	docker compose down -v
	docker system prune -f
	docker volume prune -f

clean-all: ## Clean everything including images
	@echo "🧹 Deep cleaning Docker resources..."
	docker compose down -v --rmi all
	docker system prune -af
	docker volume prune -f

# Health Checks
health: ## Check health of all services
	@echo "🏥 Checking service health..."
	@curl -s http://localhost:8000/health | jq . || echo "Backend: ❌ Not healthy"
	@curl -s http://localhost:5173 > /dev/null && echo "Frontend: ✅ Healthy" || echo "Frontend: ❌ Not healthy"

# Quick Commands
quick-start: ## Quick start for demos (build + run detached)
	@echo "⚡ Quick starting Impactor-2025..."
	docker compose up -d --build
	@echo "✅ Services starting..."
	@echo "🌐 Frontend: http://localhost:5173"
	@echo "🔧 Backend API: http://localhost:8000"
	@echo "📊 API Docs: http://localhost:8000/docs"

status: ## Show container status
	@echo "📊 Container Status:"
	docker compose ps

# Setup
setup: ## Initial setup (copy env file)
	@echo "🔧 Setting up environment..."
	@cp .env.example .env
	@echo "✅ Copied .env.example to .env"
	@echo "📝 Please edit .env with your configuration"

# Production deployment
deploy: ## Deploy to production
	@echo "🚀 Deploying to production..."
	docker compose -f docker compose.prod.yml up -d --build
	@echo "✅ Production deployment complete!"