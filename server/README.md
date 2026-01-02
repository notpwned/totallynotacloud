# totallynotacloud Server

Zero-knowledge encrypted file exchange server.

## Quick Start

### Prerequisites
- Docker Desktop installed and running
- Node.js 18+ (optional, for local development)

### Setup

1. Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

2. Start MongoDB and MinIO:
```bash
docker compose up -d
```

3. Install dependencies:
```bash
npm install
```

4. Run server:
```bash
npm start
```

Server runs on `http://localhost:3000`

### Testing

```bash
# Health check
curl http://localhost:3000/api/health

# Upload file
curl -X POST http://localhost:3000/api/upload \
  -H "Content-Type: application/json" \
  -d '{
    "fileId": "test-123",
    "fileName": "test.txt",
    "mimeType": "text/plain",
    "accessKeyHash": "test-hash",
    "encryptedData": "base64-encoded"
  }'

# List files
curl http://localhost:3000/api/files \
  -H "x-access-key-hash: test-hash"

# Delete file
curl -X DELETE http://localhost:3000/api/files/test-123 \
  -H "x-access-key-hash: test-hash"
```

### Management

```bash
# Stop services
docker compose down

# View logs
docker compose logs -f

# Access MinIO console
# URL: http://localhost:9001
# User: minioadmin
# Password: minioadmin
```

## Configuration

See `.env` for configuration options.
