# AstroBot

AstroBot is a scalable algorithmic trading bot designed to explore diverse markets, automate strategies, and adapt for future innovations in trading technology.

## Key Features
- Automated trading strategies with flexibility for customization
- Containerized development environment for secure and isolated testing
- Open-source under the MIT License to promote collaboration and learning
- Integration with CI/CD pipelines to ensure robust and secure development practices

## Getting Started

### Prerequisites
- Docker Engine (20.10.0 or higher)
- Docker Compose (v2.0.0 or higher)
- Git

### Quick Start
1. Clone the repository:
```bash
git clone https://github.com/cywf/AstroBot.git
cd AstroBot
```

2. Run the setup script:
```bash
chmod +x setup.sh
./setup.sh
```

The setup script will:
- Check for required dependencies
- Create necessary directories
- Guide you through configuration
- Start the Docker containers

### Manual Setup
If you prefer manual setup:

1. Copy the environment template:
```bash
cp .env.template .env
```

2. Edit the `.env` file with your configuration

3. Start the services:
```bash
docker compose up -d
```

## Development Environments

### Local Development
For local development, use:
```bash
docker compose up
```

This will:
- Start all required services
- Mount local volumes for development
- Enable hot-reloading
- Forward necessary ports

### Production Deployment
For production:
```bash
docker compose -f docker-compose.yaml up -d
```

Production deployment includes:
- Resource limits for containers
- Automatic restarts
- Health checks
- Persistent volume management

## Container Architecture

AstroBot uses a multi-container architecture:

1. **Main Bot Service**
   - Python-based trading logic
   - API endpoints
   - WebSocket connections

2. **Database (PostgreSQL)**
   - Persistent storage
   - Trading history
   - User configurations

3. **Redis**
   - Caching
   - Message queue
   - Real-time data

## Configuration

### Environment Variables
All configuration is done through environment variables. See `.env.template` for available options:

- Exchange API credentials
- Database configuration
- Redis settings
- Core bot parameters

### Docker Configuration
- `Dockerfile`: Multi-stage build for optimal image size
- `docker-compose.yaml`: Service orchestration and resource management

## Props to MoonDev
AstroBot's foundation was inspired by the incredible resources and teaching provided by [MoonDev](https://www.youtube.com/@moondevonyt). If you're interested in diving deeper into algorithmic trading, I highly recommend his **15-Day Bootcamp**, which offers a structured and comprehensive introduction to building trading bots. You can learn more about it [here](https://algotradecamp.com/2024-update57970432).

## Why the MIT License?
AstroBot is open-source under the [MIT License](LICENSE), which aligns with the project's goals of fostering collaboration and community-driven development. By using the MIT License:
- Developers are free to use, modify, and distribute the project with minimal restrictions
- It encourages innovation and transparency, allowing others to contribute or fork the project

## Roadmap

This is an evolving project. Key milestones include:
- [ ] Setting up initial trading bot strategies
- [ ] Implementing CI/CD pipelines with GitHub Actions
- [ ] Scaling and refining the bot for real-world application

## Contributing
Please read our [Contributing Guidelines](instructions/collaboration.md) for details on our code of conduct and the process for submitting pull requests.

## Security
For security considerations and best practices, see our [Security Documentation](instructions/security.md).

## Documentation
Full documentation is available in the [instructions](instructions/) directory.
