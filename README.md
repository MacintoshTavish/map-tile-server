# nginx Map Tile Server

A custom map tile server built with nginx and Leaflet featuring intelligent tile proxying and caching for unlimited zoom levels.

## Live Demo

Visit: http://map.localhost:3000 (local setup required)

## Features

- **Hybrid Tile Serving**: Serves local tiles first, proxies from OpenStreetMap on-demand
- **Intelligent Caching**: 500MB nginx proxy cache with 8-day validity
- **Unlimited Zoom**: Zoom levels 0-18 via OpenStreetMap tile proxy
- **Rate Limiting**: 10 req/s per IP for abuse protection
- **Cache Monitoring**: X-Cache-Status header shows HIT/MISS/BYPASS
- **CORS Enabled**: Cross-origin access for tiles
- **Real-time UI**: Live zoom level and coordinate display

## Tech Stack

- **nginx** 1.29.4 - Reverse proxy with caching
- **Leaflet** 1.9.4 - Interactive maps
- **OpenStreetMap** - Upstream tile source

## Project Structure

```
map-tile-server/
├── nginx/
│   └── map-tile-server.conf   # nginx server configuration
├── public/
│   └── index.html              # Frontend UI
├── tiles/                      # Local tiles (zoom 0-4)
│   └── {z}/{x}/{y}.png
├── cache/                      # nginx proxy cache (gitignored)
├── .gitignore
└── README.md
```

## How It Works

### Hybrid Tile Serving Strategy

1. **Request arrives**: `http://map.localhost:3000/tiles/5/10/10.png`
2. **nginx checks local**: Does `tiles/5/10/10.png` exist?
   - **YES**: Serve local file (fast)
   - **NO**: Fall back to `@tile_proxy`
3. **Proxy location**:
   - Check nginx cache (500MB on disk)
   - **Cache HIT**: Serve from cache
   - **Cache MISS**: Fetch from OpenStreetMap, cache it, serve
4. **Browser caching**: Client caches tile for 3 days

### Caching Layers

| Layer | Duration | Purpose |
|-------|----------|---------|
| Browser Cache | 3 days | Instant repeat visits |
| nginx Proxy Cache | 8 days | Shared cache for all users |
| Local Tiles | Forever | Offline availability (zoom 0-4) |

## Setup

### 1. Install nginx (macOS)

```bash
brew install nginx
```

### 2. Clone Repository

```bash
git clone https://github.com/MacintoshTavish/map-tile-server.git
cd map-tile-server
```

### 3. Configure nginx

Copy the nginx configuration to nginx servers directory:

```bash
cp nginx/map-tile-server.conf /opt/homebrew/etc/nginx/servers/
```

**Important:** Edit `/opt/homebrew/etc/nginx/servers/map-tile-server.conf` and update paths:

```nginx
# Line 5: Update cache path
proxy_cache_path /YOUR/PATH/TO/map-tile-server/cache

# Line 22: Update public path
root /YOUR/PATH/TO/map-tile-server/public;

# Line 30: Update tiles path
root /YOUR/PATH/TO/map-tile-server;
```

Replace `/YOUR/PATH/TO/` with your actual absolute path.

### 4. Create Cache Directory

```bash
mkdir cache
```

### 5. Download Local Tiles (Optional)

Local tiles for zoom 0-4 are included in the repo. To re-download:

```bash
# Download zoom level 0
mkdir -p tiles/0/0
curl -o tiles/0/0/0.png "https://tile.openstreetmap.org/0/0/0.png"

# Download zoom levels 1-4
for z in 1 2 3 4; do
  for x in 0 1; do
    for y in 0 1; do
      mkdir -p tiles/${z}/${x}
      curl -s -o tiles/${z}/${x}/${y}.png \
        "https://tile.openstreetmap.org/${z}/${x}/${y}.png"
      echo "Downloaded ${z}/${x}/${y}.png"
      sleep 0.5
    done
  done
done
```

**Note**: Even without local tiles, the proxy will fetch everything on-demand.

### 6. Test Configuration

```bash
nginx -t
```

### 7. Start/Reload nginx

```bash
# Start
brew services start nginx

# Or reload if already running
nginx -s reload
```

### 8. Open in Browser

```
http://map.localhost:3000
```

## Usage

### Monitor Cache Performance

Open browser DevTools → Network tab → Click any tile request → Check Response Headers:

```http
X-Cache-Status: HIT    # Served from nginx cache
X-Cache-Status: MISS   # Fetched from OpenStreetMap
```

### View Logs

```bash
# Access logs (all requests)
tail -f /opt/homebrew/var/log/nginx/map-tile-server.access.log

# Error logs
tail -f /opt/homebrew/var/log/nginx/map-tile-server.error.log
```

### Check Cache Size

```bash
du -sh cache/
```

### Clear Cache

```bash
rm -rf cache/*
nginx -s reload
```

## nginx Configuration Explained

### Rate Limiting
```nginx
limit_req_zone $binary_remote_addr zone=tile_limit:10m rate=10r/s;
limit_req zone=tile_limit burst=20 nodelay;
```
Limits to 10 requests/second per IP, allows burst of 20.

### Proxy Caching
```nginx
proxy_cache_path /path/to/cache
                 levels=1:2              # Two-level directory structure
                 keys_zone=tile_cache:10m # 10MB for cache keys
                 max_size=500m            # Max 500MB cache
                 inactive=7d              # Remove unused tiles after 7 days
                 use_temp_path=on;
```

### Hybrid Serving
```nginx
location ~ ^/tiles/(\d+)/(\d+)/(\d+)\.png$ {
    try_files /tiles/$1/$2/$3.png @tile_proxy;  # Local first, proxy fallback
}
```

### Cache Status Header
```nginx
add_header X-Cache-Status $upstream_cache_status;
```
Shows if tile came from cache (HIT) or was fetched (MISS).

### DNS Resolver
```nginx
resolver 8.8.8.8 8.8.4.4 valid=300s;
```
Required for nginx to resolve `tile.openstreetmap.org`.

## What I Learned

- nginx reverse proxy with caching
- Hybrid serving strategies (local + proxy)
- Two-tier caching (browser + server)
- Cache invalidation policies
- HTTP cache headers (Cache-Control, Expires)
- Map tile coordinate systems (z/x/y)
- Rate limiting for abuse protection
- DNS resolution in nginx
- CORS for public tile APIs
- Regex location matching in nginx

## Commands Reference

```bash
# Test nginx config
nginx -t

# Reload nginx (zero downtime)
nginx -s reload

# Stop nginx
brew services stop nginx

# Check if tile is served
curl -I http://map.localhost:3000/tiles/5/10/10.png

# Check cache status
curl -I http://map.localhost:3000/tiles/10/500/300.png | grep X-Cache-Status

# View real-time access logs
tail -f /opt/homebrew/var/log/nginx/map-tile-server.access.log

# Count cached tiles
find cache/ -name "*.png" 2>/dev/null | wc -l

# Cache size
du -sh cache/
```

## Troubleshooting

### Tiles not loading
```bash
# Check nginx is running
brew services list | grep nginx

# Check error logs
tail -20 /opt/homebrew/var/log/nginx/map-tile-server.error.log

# Test config syntax
nginx -t
```

### Cache not working
- Check `X-Cache-Status` header (should show HIT after second request)
- Verify cache directory exists and is writable
- Check cache size: `du -sh cache/`

### DNS resolution errors
- Verify DNS resolver is configured: `resolver 8.8.8.8 8.8.4.4;`
- Test DNS: `nslookup tile.openstreetmap.org 8.8.8.8`

## Future Enhancements

- [ ] Multiple tile layers (satellite, terrain)
- [ ] Search functionality (geocoding)
- [ ] Backend API for markers
- [ ] HTTPS/SSL
- [ ] Compression (gzip)
- [ ] Real-time location tracking
- [ ] Heat maps
- [ ] Drawing tools
- [ ] Analytics dashboard

## Resources

- [nginx Proxy Module](https://nginx.org/en/docs/http/ngx_http_proxy_module.html)
- [nginx Caching Guide](https://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_cache)
- [Leaflet Documentation](https://leafletjs.com/)
- [OpenStreetMap Tile Usage Policy](https://operations.osmfoundation.org/policies/tiles/)

## License

MIT

## Author

mac
