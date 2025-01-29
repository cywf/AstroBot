#!/usr/bin/env bash

# Set strict error handling
set -euo pipefail
IFS=$'\n\t'

# Color codes for better UX
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color
readonly BOLD='\033[1m'

# Show help message
show_help() {
    cat << EOF
AstroBot Setup Script

Usage: ./setup.sh [OPTIONS]

Options:
  -h, --help     Show this help message
  -n, --non-interactive  Run in non-interactive mode (requires .env.template)
  
This script sets up AstroBot's local development environment.
EOF
    exit 0
}

# Function to validate input
validate_input() {
    local input=$1
    local field=$2
    if [[ -z "$input" ]]; then
        print_message "$RED" "❌ $field cannot be empty"
        return 1
    fi
    if [[ "$field" == *"Password"* && ${#input} -lt 8 ]]; then
        print_message "$RED" "❌ $field must be at least 8 characters long"
        return 1
    fi
    return 0
}

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    printf "${color}${message}${NC}\n"
}

# Function to check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_message "$RED" "❌ Docker is not installed. Please install Docker first:"
        print_message "$YELLOW" "📝 Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    if ! docker info &> /dev/null; then
        print_message "$RED" "❌ Docker daemon is not running"
        exit 1
    fi
    print_message "$GREEN" "✅ Docker is installed and running"
}

# Function to check if Docker Compose is installed
check_docker_compose() {
    if ! command -v docker compose &> /dev/null; then
        print_message "$RED" "❌ Docker Compose is not installed"
        exit 1
    fi
    print_message "$GREEN" "✅ Docker Compose is installed"
}

# Function to create directories
create_directories() {
    local dirs=("data" "logs" "secrets")
    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        print_message "$GREEN" "✅ Created directory: $dir"
    done
}

# Function to gather trading configuration
configure_trading() (
    # Create a subshell for local variable scope
    print_message "$BOLD" "🔧 Trading Configuration"
    
    local exchanges=("binance" "alpaca" "custom")
    select exchange in "${exchanges[@]}"; do
        case $exchange in
            binance)
                while true; do
                    read -p "Enter Binance API Key: " BINANCE_API_KEY
                    validate_input "$BINANCE_API_KEY" "API Key" && break
                done
                while true; do
                    read -p "Enter Binance API Secret: " BINANCE_API_SECRET
                    validate_input "$BINANCE_API_SECRET" "API Secret" && break
                done
                echo "EXCHANGE_TYPE=binance" >> .env
                echo "BINANCE_API_KEY=$BINANCE_API_KEY" >> .env
                echo "BINANCE_API_SECRET=$BINANCE_API_SECRET" >> .env
                break
                ;;
            alpaca)
                read -p "Enter Alpaca API Key: " ALPACA_API_KEY
                read -p "Enter Alpaca API Secret: " ALPACA_API_SECRET
                echo "EXCHANGE_TYPE=alpaca" >> .env
                echo "ALPACA_API_KEY=$ALPACA_API_KEY" >> .env
                echo "ALPACA_API_SECRET=$ALPACA_API_SECRET" >> .env
                break
                ;;
            custom)
                read -p "Enter Exchange Name: " EXCHANGE_NAME
                read -p "Enter API Key: " API_KEY
                read -p "Enter API Secret: " API_SECRET
                echo "EXCHANGE_TYPE=$EXCHANGE_NAME" >> .env
                echo "API_KEY=$API_KEY" >> .env
                echo "API_SECRET=$API_SECRET" >> .env
                break
                ;;
        esac
    done
)

# Function to configure database
configure_database() (
    # Create a subshell for local variable scope
    print_message "$BOLD" "🗄️ Database Configuration"
    
    read -p "Enter PostgreSQL Password: " DB_PASSWORD
    read -p "Enter PostgreSQL Database Name [astrobot]: " DB_NAME
    DB_NAME=${DB_NAME:-astrobot}
    
    cat << EOF >> .env
POSTGRES_PASSWORD=$DB_PASSWORD
POSTGRES_DB=$DB_NAME
POSTGRES_USER=astrobot
DB_HOST=db
DB_PORT=5432
EOF
)

# Function to configure Redis
configure_redis() (
    # Create a subshell for local variable scope
    print_message "$BOLD" "📊 Redis Configuration"
    
    read -p "Enter Redis Password: " REDIS_PASSWORD
    
    cat << EOF >> .env
REDIS_PASSWORD=$REDIS_PASSWORD
REDIS_HOST=redis
REDIS_PORT=6379
EOF
)

# Main setup function
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                ;;
            -n|--non-interactive)
                if [[ ! -f .env.template ]]; then
                    print_message "$RED" "❌ Non-interactive mode requires .env.template file"
                    exit 1
                fi
                cp .env.template .env
                exit 0
                ;;
            *)
                print_message "$RED" "❌ Unknown option: $1"
                show_help
                ;;
        esac
        shift
    done

    print_message "$BOLD" "🚀 Welcome to AstroBot Setup"
    
    # Check prerequisites
    check_docker
    check_docker_compose
    
    # Create necessary directories
    create_directories
    
    # Create .env file
    if [[ -f .env ]]; then
        print_message "$YELLOW" "⚠️ Existing .env file found. Creating backup..."
        cp .env ".env.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Generate secure secret key
    print_message "$GREEN" "🔑 Generating secure secret key..."
    echo "SECRET_KEY=$(openssl rand -hex 32)" > .env
    
    # Configure components
    configure_trading
    configure_database
    configure_redis
    
    # Add additional environment variables
    cat << EOF >> .env
LOG_LEVEL=INFO
ENVIRONMENT=production
PORT=8000
EOF
    
    print_message "$GREEN" "✅ Configuration complete! Starting services..."
    
    # Pull and start services
    docker compose pull
    docker compose up -d
    
    print_message "$GREEN" "🎉 AstroBot is now running!"
    print_message "$YELLOW" "📝 Check logs with: docker compose logs -f"
}

# Execute main function
main "$@" 