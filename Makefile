.PHONY: help server tunnel tunnel-bg build test clean install lint

.DEFAULT_GOAL := help

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)Our Memories Together - Development Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

install: ## Install dependencies (npm + Python)
	@echo "$(BLUE)Installing dependencies...$(NC)"
	npm install
	python3 -m pip install -r requirements.txt 2>/dev/null || echo "No requirements.txt found"

server: ## Start server locally (http://localhost:8888)
	@echo "$(BLUE)Starting server at http://localhost:8888$(NC)"
	@echo "Password: $$(grep BIRTHDAY_PAGE_PASSWORD .env | cut -d= -f2)"
	@source .env && python3 server.py

tunnel: ## Start Cloudflare tunnel (keeps tunnel + server running)
	@echo "$(BLUE)Starting server + Cloudflare tunnel...$(NC)"
	@source .env && python3 server.py &
	@sleep 2
	@echo "$(GREEN)Tunnel URL:$(NC)"
	@cloudflared tunnel --url http://localhost:8888

tunnel-bg: ## Start tunnel in background (run 'make server' in another terminal)
	@echo "$(BLUE)Starting Cloudflare tunnel (background mode)$(NC)"
	@echo "Run 'make server' in another terminal to start the app server"
	@cloudflared tunnel --url http://localhost:8888

build: ## Build minified CSS/JS for production
	@echo "$(BLUE)Building minified assets...$(NC)"
	npm run build
	@echo "$(GREEN)✓ Minification complete$(NC)"
	@ls -lh *.min.js *.min.css

test: ## Run test suite
	@echo "$(BLUE)Running tests...$(NC)"
	python3 -m pytest test_server.py -v 2>/dev/null || python3 -m unittest test_server -v

test-quick: ## Quick test (same as test but shorter)
	@python3 -m unittest test_server -v 2>&1 | tail -20

deploy-firebase: ## Deploy Firebase rules to console
	@echo "$(BLUE)Deploying Firebase rules...$(NC)"
	@echo "$(GREEN)Database rules:$(NC)"
	npx firebase deploy --only database
	@echo ""
	@echo "$(GREEN)Storage rules (after manual setup):$(NC)"
	@echo "  npx firebase deploy --only storage"

lint: ## Check for errors/warnings
	@echo "$(BLUE)Checking for errors...$(NC)"
	@python3 -m py_compile server.py test_server.py && echo "$(GREEN)✓ Python files OK$(NC)" || true

clean: ## Remove cache, logs, and minified files
	@echo "$(BLUE)Cleaning up...$(NC)"
	rm -rf __pycache__ .pytest_cache *.log
	rm -f *.min.js *.min.css
	@echo "$(GREEN)✓ Cleaned$(NC)"

dev: ## Start development mode (server + watch)
	@echo "$(BLUE)Development mode: watching for changes...$(NC)"
	@make build
	@make server

help-passwords: ## Show configured passwords
	@echo "$(BLUE)Configured Passwords:$(NC)"
	@grep -E "BIRTHDAY_PAGE_PASSWORD|ADMIN_PAGE_PASSWORD" .env

env-setup: ## Setup .env file from .env.example
	@if [ ! -f .env ]; then \
		echo "$(BLUE)Creating .env from .env.example...$(NC)"; \
		cp .env.example .env; \
		echo "$(GREEN)✓ .env created. Edit it with your passwords.$(NC)"; \
	else \
		echo "$(GREEN)✓ .env already exists$(NC)"; \
	fi

status: ## Check server status
	@echo "$(BLUE)Checking server status...$(NC)"
	@curl -s http://localhost:8888/health 2>/dev/null | python3 -m json.tool || echo "Server not running"

kill-tunnel: ## Kill background tunnel
	@pkill -f "cloudflared tunnel" && echo "$(GREEN)✓ Tunnel stopped$(NC)" || echo "No tunnel running"

kill-server: ## Kill background server
	@pkill -f "python.*server.py" && echo "$(GREEN)✓ Server stopped$(NC)" || echo "No server running"

ps: ## Show running tunnels and servers
	@echo "$(BLUE)Running processes:$(NC)"
	@ps aux | grep -E "cloudflared|python.*server" | grep -v grep || echo "None"

# Quick shortcuts
s: server ## Alias: make server
t: tunnel ## Alias: make tunnel
tb: tunnel-bg ## Alias: make tunnel-bg
b: build ## Alias: make build
ts: test ## Alias: make test
