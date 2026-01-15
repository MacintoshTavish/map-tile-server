# nginx Map Tile Server

A custom map tile server built with nginx and Leaflet to understand how real-world mapping services work.

## Live Demo

Visit: http://map.localhost:3000 (local setup required)

## Features

- Serves OpenStreetMap tiles via nginx
- Interactive map with zoom levels 0-4
- Rate limiting (10 req/s) for abuse protection
- CORS enabled for cross-origin access
- Aggressive 30-day caching
- Real-time zoom level indicator
- Live coordinate display

## Tech Stack

- **nginx** 1.29.4 - Static file server
- **Leaflet** 1.9.4 - Interactive maps
- **OpenStreetMap** - Tile source

## Project Structure

```
map-tile-server/
├── tiles/          # Map tiles (PNG images)
│   └── {z}/{x}/{y}.png
└── public/         # Frontend
    └── index.html
```

## Setup

### 1. Install nginx (macOS)

```bash
brew install nginx
```

### 2. Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/map-tile-server.git
cd map-tile-server
```

### 3. Configure nginx

Create `/opt/homebrew/etc/nginx/servers/map-tile-server.conf`:

```nginx
# Rate limiting zone
limit_req_zone $binary_remote_addr zone=tile_limit:10m rate=10r/s;

server {
    listen 3000;
    server_name map.localhost;

    location / {
        root /path/to/map-tile-server/public;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    location /tiles/ {
        alias /path/to/map-tile-server/tiles/;
        limit_req zone=tile_limit burst=20 nodelay;

        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, OPTIONS';

        expires 30d;
        add_header Cache-Control "public, immutable";

        types {
            image/png png;
        }
    }

    access_log /opt/homebrew/var/log/nginx/map-tile-server.access.log;
    error_log /opt/homebrew/var/log/nginx/map-tile-server.error.log;
}
```

**Important:** Update paths to match your local setup.

### 4. Download Tiles

```bash
cd tiles

# Download zoom level 0
curl -o 0/0/0.png "https://tile.openstreetmap.org/0/0/0.png"

# Download zoom levels 1-4
for z in 1 2 3 4; do
  for x in 0 1; do
    for y in 0 1; do
      mkdir -p ${z}/${x}
      curl -s -o ${z}/${x}/${y}.png \
        "https://tile.openstreetmap.org/${z}/${x}/${y}.png"
      echo "Downloaded ${z}/${x}/${y}.png"
      sleep 0.5
    done
  done
done
```

### 5. Test Configuration

```bash
nginx -t
```

### 6. Start/Reload nginx

```bash
# Start
brew services start nginx

# Or reload if already running
nginx -s reload
```

### 7. Open in Browser

```
http://map.localhost:3000
```

## What I Learned

- nginx static file serving
- HTTP caching strategies
- CORS and browser security
- Map tile coordinate systems
- Rate limiting for abuse protection
- Zero-downtime configuration reloads

## nginx Configuration Explained

### Rate Limiting
```nginx
limit_req_zone $binary_remote_addr zone=tile_limit:10m rate=10r/s;
limit_req zone=tile_limit burst=20 nodelay;
```
Limits to 10 requests/second per IP, allows burst of 20.

### Caching
```nginx
expires 30d;
add_header Cache-Control "public, immutable";
```
Tiles cached for 30 days - instant load on repeat visits.

### CORS
```nginx
add_header 'Access-Control-Allow-Origin' '*';
```
Allows tiles to be loaded from any origin (standard for public tiles).

## Commands

```bash
# Test config
nginx -t

# Reload config
nginx -s reload

# View access logs
tail -f /opt/homebrew/var/log/nginx/map-tile-server.access.log

# View error logs
tail -f /opt/homebrew/var/log/nginx/map-tile-server.error.log

# Check if tile is served
curl -I http://map.localhost:3000/tiles/0/0/0.png
```

## Future Enhancements

- [ ] Tile proxy with caching
- [ ] Multiple tile layers (satellite, terrain)
- [ ] Search functionality (geocoding)
- [ ] Backend API for markers
- [ ] HTTPS/SSL
- [ ] Compression (gzip)
- [ ] Real-time location tracking
- [ ] Heat maps
- [ ] Drawing tools
- [ ] Monitoring dashboard

## Resources

- [nginx Documentation](https://nginx.org/en/docs/)
- [Leaflet Documentation](https://leafletjs.com/)
- [OpenStreetMap Tiles](https://wiki.openstreetmap.org/wiki/Tiles)

## License

MIT

## Author

mac
