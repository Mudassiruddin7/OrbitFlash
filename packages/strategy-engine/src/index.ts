import express from 'express';
import dotenv from 'dotenv';
import { StrategyEngineService } from './main.js';

// Load environment variables
dotenv.config();

const app = express();
const port = process.env.PORT || 3002;

// Middleware
app.use(express.json());

// Initialize the strategy engine service
const strategyService = new StrategyEngineService();

// Health check endpoint
app.get('/health', (_req, res) => {
  res.json(strategyService.getHealthStatus());
});

// Queue status endpoint
app.get('/queue/stats', (_req, res) => {
  res.json(strategyService.getQueueStats());
});

// Queue size endpoint
app.get('/queue/size', (_req, res) => {
  res.json({ size: strategyService.getQueueSize() });
});

// Clear queue endpoint
app.post('/queue/clear', (_req, res) => {
  strategyService.clearQueue();
  res.json({ success: true, message: 'Queue cleared' });
});

// Scorer configuration endpoints
app.get('/config/scorer', (_req, res) => {
  res.json(strategyService.getScorerConfig());
});

app.post('/config/scorer', async (req, res) => {
  try {
    await strategyService.updateScorerConfig(req.body);
    res.json({ success: true, message: 'Scorer configuration updated' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update scorer configuration' });
  }
});

// Risk manager configuration endpoints
app.get('/config/risk', (_req, res) => {
  res.json(strategyService.getRiskConfig());
});

app.post('/config/risk', async (req, res) => {
  try {
    await strategyService.updateRiskConfig(req.body);
    res.json({ success: true, message: 'Risk configuration updated' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update risk configuration' });
  }
});

// Blacklist management endpoints
app.post('/blacklist/token/:token', (req, res) => {
  strategyService.addBlacklistedToken(req.params.token);
  res.json({ success: true, message: `Token ${req.params.token} blacklisted` });
});

app.delete('/blacklist/token/:token', (req, res) => {
  strategyService.removeBlacklistedToken(req.params.token);
  res.json({ success: true, message: `Token ${req.params.token} removed from blacklist` });
});

app.post('/blacklist/dex/:dex', (req, res) => {
  strategyService.addBlacklistedDex(req.params.dex);
  res.json({ success: true, message: `DEX ${req.params.dex} blacklisted` });
});

app.delete('/blacklist/dex/:dex', (req, res) => {
  strategyService.removeBlacklistedDex(req.params.dex);
  res.json({ success: true, message: `DEX ${req.params.dex} removed from blacklist` });
});

// Opportunities by urgency endpoint
app.get('/opportunities/:urgency', (req, res) => {
  const urgency = req.params.urgency as 'low' | 'medium' | 'high';
  const opportunities = strategyService.getOpportunitiesByUrgency(urgency);
  res.json(opportunities);
});

// Start the service and server
async function startServer() {
  try {
    // Start the strategy engine service
    await strategyService.start();
    
    // Start the Express server
    app.listen(port, () => {
      console.log(`🚀 Strategy Engine Service running on port ${port}`);
      console.log(`📊 Health check: http://localhost:${port}/health`);
      console.log(`📈 Queue stats: http://localhost:${port}/queue/stats`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('Shutting down gracefully...');
  await strategyService.stop();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('Shutting down gracefully...');
  await strategyService.stop();
  process.exit(0);
});

// Start the server
startServer();
