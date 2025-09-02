import express from 'express';
import dotenv from 'dotenv';
import { GasOptimizerService } from './main.js';

// Load environment variables
dotenv.config();

const app = express();
const port = process.env.PORT || 3003;

// Middleware
app.use(express.json());

// Initialize the gas optimizer service
const gasService = new GasOptimizerService();

// Health check endpoint
app.get('/health', (_req, res) => {
  res.json(gasService.getHealthStatus());
});

// Current gas info endpoint
app.get('/gas/current', async (_req, res) => {
  try {
    const gasInfo = await gasService.getCurrentGasInfo();
    res.json(gasInfo);
  } catch (error) {
    res.status(500).json({ error: 'Failed to get current gas info' });
  }
});

// Gas price recommendations endpoint
app.get('/gas/recommendations', async (_req, res) => {
  try {
    const recommendations = await gasService.getGasPriceRecommendations();
    res.json(recommendations);
  } catch (error) {
    res.status(500).json({ error: 'Failed to get gas recommendations' });
  }
});

// Gas configuration endpoints
app.get('/config/gas', (_req, res) => {
  res.json(gasService.getGasConfig());
});

app.post('/config/gas', (req, res) => {
  try {
    gasService.updateGasConfig(req.body);
    res.json({ success: true, message: 'Gas configuration updated' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update gas configuration' });
  }
});

// Contract address management
app.get('/contract/address', (_req, res) => {
  res.json({ address: gasService.getContractAddress() });
});

app.post('/contract/address', (req, res) => {
  try {
    const { address } = req.body;
    gasService.setContractAddress(address);
    res.json({ success: true, message: 'Contract address updated' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update contract address' });
  }
});

// Test gas optimization endpoint
app.post('/test/optimize', async (req, res) => {
  try {
    const opportunity = req.body;
    const result = await gasService.testGasOptimization(opportunity);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: 'Failed to test gas optimization' });
  }
});

// Start the service and server
async function startServer() {
  try {
    // Start the gas optimizer service
    await gasService.start();
    
    // Start the Express server
    app.listen(port, () => {
      console.log(`🚀 Gas Optimizer Service running on port ${port}`);
      console.log(`📊 Health check: http://localhost:${port}/health`);
      console.log(`⛽ Gas info: http://localhost:${port}/gas/current`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('Shutting down gracefully...');
  await gasService.stop();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('Shutting down gracefully...');
  await gasService.stop();
  process.exit(0);
});

// Start the server
startServer();
