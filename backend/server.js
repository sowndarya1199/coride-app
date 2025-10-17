const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Mock ride data
const mockRides = [
  {
    driver_id: 'driver_001',
    driver_name: 'John Smith',
    vehicle_type: 'Auto',
    available_seats: 2,
    price_estimate: 120.0,
    eta_minutes: 5,
    match_score: 0.85,
    pickup_location: { lat: 12.9716, lng: 77.5946 },
    dropoff_location: { lat: 12.9352, lng: 77.6245 },
    route_polyline: [
      { lat: 12.9716, lng: 77.5946 },
      { lat: 12.9600, lng: 77.6000 },
      { lat: 12.9500, lng: 77.6100 },
      { lat: 12.9352, lng: 77.6245 }
    ],
    cluster_id: 'cluster_1',
    detour_distance: 300.0,
    path_overlap_percentage: 0.75
  },
  {
    driver_id: 'driver_002',
    driver_name: 'Sarah Johnson',
    vehicle_type: 'Cab',
    available_seats: 4,
    price_estimate: 180.0,
    eta_minutes: 8,
    match_score: 0.72,
    pickup_location: { lat: 12.9750, lng: 77.5900 },
    dropoff_location: { lat: 12.9400, lng: 77.6200 },
    route_polyline: [
      { lat: 12.9750, lng: 77.5900 },
      { lat: 12.9650, lng: 77.5950 },
      { lat: 12.9550, lng: 77.6050 },
      { lat: 12.9400, lng: 77.6200 }
    ],
    cluster_id: 'cluster_1',
    detour_distance: 500.0,
    path_overlap_percentage: 0.65
  },
  {
    driver_id: 'driver_003',
    driver_name: 'Mike Wilson',
    vehicle_type: 'Auto',
    available_seats: 1,
    price_estimate: 100.0,
    eta_minutes: 3,
    match_score: 0.90,
    pickup_location: { lat: 12.9700, lng: 77.5950 },
    dropoff_location: { lat: 12.9300, lng: 77.6250 },
    route_polyline: [
      { lat: 12.9700, lng: 77.5950 },
      { lat: 12.9600, lng: 77.6000 },
      { lat: 12.9500, lng: 77.6100 },
      { lat: 12.9300, lng: 77.6250 }
    ],
    cluster_id: 'cluster_2',
    detour_distance: 200.0,
    path_overlap_percentage: 0.85
  }
];

// Search endpoint
app.post('/api/v1/search', (req, res) => {
  console.log('Search request received:', req.body);
  
  const { origin, destination, preferences } = req.body;
  
  // Filter rides based on preferences
  let filteredRides = mockRides.filter(ride => {
    if (preferences.vehicle_type && ride.vehicle_type !== preferences.vehicle_type) {
      return false;
    }
    if (ride.available_seats < preferences.seats_required) {
      return false;
    }
    return true;
  });
  
  // Sort by match score (highest first)
  filteredRides.sort((a, b) => b.match_score - a.match_score);
  
  const response = {
    search_id: `search_${Date.now()}`,
    expires_at: new Date(Date.now() + 5 * 60 * 1000).toISOString(), // 5 minutes
    matches: filteredRides,
    error_message: null
  };
  
  console.log('Sending response:', response);
  res.json(response);
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 CORIDE Backend running on http://localhost:${PORT}`);
  console.log(`📱 Health check: http://localhost:${PORT}/api/health`);
  console.log(`🔍 Search API: http://localhost:${PORT}/api/v1/search`);
});
