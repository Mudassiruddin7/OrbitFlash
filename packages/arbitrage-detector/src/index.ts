import express from 'express';
import dotenv from 'dotenv';
import { ArbitrageDetectorService } from './main.js';

// Load environment variables
dotenv.config();

const app = express();
const port = process.env.PORT || 3001;

// Middleware
app.use(express.json());

// Initialize the arbitrage detector service
const arbitrageService = new ArbitrageDetectorService();

// Health check endpoint
app.get('/health', (_req, res) => {
  res.json({ 
    status: 'healthy', 
    service: 'arbitrage-detector',
    timestamp: new Date().toISOString()
  });
});

// Status endpoint
app.get('/status', (_req, res) => {
  res.json({
    bufferStatus: arbitrageService.getBufferStatus(),
    config: arbitrageService.getCalculatorConfig()
  });
});

// Configuration endpoint
app.post('/config', async (req, res) => {
  try {
    await arbitrageService.updateCalculatorConfig(req.body);
    res.json({ success: true, message: 'Configuration updated' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update configuration' });
  }
});

// Start the service and server
async function startServer() {
  try {
    // Start the arbitrage detection service
    await arbitrageService.start();
    
    // Start the Express server
    app.listen(port, () => {
      console.log(`🚀 Arbitrage Detector Service running on port ${port}`);
      console.log(`📊 Health check: http://localhost:${port}/health`);
      console.log(`📈 Status: http://localhost:${port}/status`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('Shutting down gracefully...');
  await arbitrageService.stop();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('Shutting down gracefully...');
  await arbitrageService.stop();
  process.exit(0);
});

// Start the server
startServer();
