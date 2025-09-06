# OrbitFlash

Advanced MEV arbitrage system with cross-chain capabilities.

## 🏗️ Architecture

- **Microservices**: Modular design with separate services for detection, strategy, and optimization
- **Shared Types**: Common TypeScript interfaces across all services
- **Smart Contracts**: Hardhat-based flash loan arbitrage executor
- **Containerized**: Docker-based deployment with orchestration
- **Real-time**: Redis pub/sub for event-driven communication

## 📦 Services

### Core Services

- **arbitrage-detector** (Port 3001): Detects arbitrage opportunities across DEXs
- **strategy-engine** (Port 3002): Scores and prioritizes opportunities
- **gas-optimizer** (Port 3003): Optimizes gas strategies for execution
- **monitoring** (Port 8080): Web dashboard for system monitoring

### Infrastructure

- **Redis**: Caching and pub/sub messaging
- **Nginx**: Reverse proxy and load balancing

## 🚀 Quick Start

### Prerequisites

- Node.js >= 18
- PNPM >= 8
- Docker & Docker Compose

### Local Development

1. **Clone and install dependencies:**

```bash
git clone <repository>
cd orbitflash
pnpm install
```

2. **Build all packages:**

```bash
pnpm build
```

3. **Start with Docker Compose:**

```bash
# Start all services
docker-compose up -d

# For development with hot reload
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

4. **Access services:**

- Monitoring Dashboard: http://localhost:8080
- Arbitrage Detector API: http://localhost:3001
- Strategy Engine API: http://localhost:3002
- Gas Optimizer API: http://localhost:3003
- Redis Commander (dev): http://localhost:8081

### Manual Development

```bash
# Start Redis
docker run -d -p 6379:6379 redis:alpine

# Start each service in separate terminals
cd packages/arbitrage-detector && pnpm dev
cd packages/strategy-engine && pnpm dev
cd packages/gas-optimizer && pnpm dev
```

## 🔧 Configuration

### Environment Variables

Copy in `.env` and configure:

```bash
# -------- Arbitrum Sepolia --------
ARBITRUM_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc
ARBITRUM_WS_URL=wss://sepolia-rollup.arbitrum.io/ws

# -------- Smart Contract Address --------
# Replace after deployment
ORBIT_FLASH_CONTRACT_ADDRESS=

# -------- Routers (these may not exist on Sepolia, leave 0x0 if not deployed) --------
UNISWAP_V3_ROUTER=0xE592427A0AEce92De3Edee1F18E0157C05861564
SUSHISWAP_ROUTER=0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506
BALANCER_VAULT=0xBA12222222228d8Ba445958a75a0704d566BF2C8

# -------- Optimization --------
MIN_PROFIT_THRESHOLD=0.01
MAX_SLIPPAGE=0.005
GAS_PRICE_BUFFER_PERCENT=10

# -------- Arbiscan API Key (needed for verification) --------
ARBISCAN_API_KEY=

# -------- Deployment Wallet --------
# ⚠️ Test wallet only, not your main funds wallet
PRIVATE_KEY=

```

## 📊 System Flow

1. **Detection**: Arbitrage detector monitors DEX prices and identifies opportunities
2. **Scoring**: Strategy engine evaluates opportunities using profit/risk/competition metrics
3. **Optimization**: Gas optimizer prepares transactions with optimal gas strategies
4. **Execution**: Smart contract executes flash loan arbitrage trades
5. **Monitoring**: Real-time dashboard tracks system performance

## 🔗 API Endpoints

### Arbitrage Detector

- `GET /health` - Service health check
- `GET /status` - Detection statistics
- `GET /config` - Current configuration

### Strategy Engine

- `GET /health` - Service health check
- `GET /queue` - Priority queue status
- `POST /config` - Update scoring configuration
- `GET /blacklist` - View blacklisted tokens

### Gas Optimizer

- `GET /health` - Service health check
- `GET /gas/current` - Current gas information
- `GET /gas/recommendations` - Gas price recommendations
- `POST /test/optimize` - Test gas optimization

## 🏗️ Smart Contracts

Deploy the OrbitFlashArbitrage contract:

```bash
cd contracts
# Configure PRIVATE_KEY and ARBITRUM_RPC_URL
pnpm hardhat deploy --network arbitrum
```

## 📈 Monitoring

The monitoring dashboard provides:

- Real-time service health status
- System performance metrics
- Arbitrage opportunity statistics
- Gas optimization insights
- Redis cache status

## 🐳 Docker Commands

```bash
# Build all images
docker-compose build

# Start services
docker-compose up -d

# View logs
docker-compose logs -f [service-name]

# Stop services
docker-compose down

# Remove volumes
docker-compose down -v
```

## 🔒 Security

- Smart contracts use OpenZeppelin security patterns
- Owner-only access control for critical functions
- Reentrancy protection on flash loan callbacks
- Input validation and slippage protection
- Non-root Docker containers

## 🛠️ Development

### Adding New DEX Support

1. Update `DexCalldataGenerator` in gas-optimizer
2. Add DEX-specific price feeds in arbitrage-detector
3. Update configuration and environment variables

### Extending Monitoring

1. Add new metrics to service health endpoints
2. Update monitoring dashboard HTML/JavaScript
3. Configure Nginx proxy routes

## 📝 License

MIT License - see LICENSE file for details

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes with tests
4. Submit pull request

## 📞 Support

For issues and questions:

- Create GitHub issue
- Check documentation
- Review logs: `docker-compose logs`

## Requirements

- Node.js >= 18.0.0
- PNPM >= 8.0.0
