// Vercel serverless function
export default function handler(req, res) {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader('Access-Control-Allow-Headers', 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { origin, destination, preferences } = req.body;
  
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
    }
  ];

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

  // Sort by match score
  filteredRides.sort((a, b) => b.match_score - a.match_score);

  const response = {
    search_id: `search_${Date.now()}`,
    expires_at: new Date(Date.now() + 5 * 60 * 1000).toISOString(),
    matches: filteredRides,
    error_message: null
  };

  res.status(200).json(response);
}
