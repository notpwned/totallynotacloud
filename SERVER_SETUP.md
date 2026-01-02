# Server Setup Guide - Privacy-First Architecture

## Overview

The server is designed with zero-knowledge encryption. The server never stores plain data or user information. All files are encrypted client-side before upload, and the server only stores encrypted blobs identified by access key hashes.

## Architecture Principles

1. **No User Accounts** - No username/password, no personal data collection
2. **Key-Based Access** - Access via encrypted RSA keys only
3. **Zero-Knowledge** - Server cannot decrypt files (private key stays on client)
4. **Memory Encryption** - RAM is encrypted to prevent memory dumps
5. **No Logs** - No access logs, no metadata about who accessed what
6. **Ephemeral** - Files can have expiration dates
7. **Access Control** - Granular permissions per key

## Technology Stack

- **Runtime**: Node.js 18+ or Go 1.21+
- **Database**: MongoDB or PostgreSQL (metadata only, no file content)
- **Storage**: S3-compatible (MinIO, AWS S3, etc.) with server-side encryption
- **Encryption**: AES-256-GCM for file storage, RSA-2048 for key exchange

## Node.js Implementation Example

### Setup

```bash
mkdir totallynotacloud-server
cd totallynotacloud-server
npm init -y
npm install express crypto dotenv mongodb axios
```

### Environment Variables (.env)

```
PORT=3000
MONGODB_URI=mongodb://localhost:27017/totallynotacloud
S3_ENDPOINT=http://localhost:9000
S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin
S3_BUCKET=encrypted-files
ENCRYPTION_KEY=your-64-char-hex-key-for-aes-256
SERVER_PRIVATE_KEY=your-rsa-private-key
MAX_FILE_SIZE=10737418240
FILE_RETENTION_DAYS=90
```

### Core Server Implementation (server.js)

```javascript
const express = require('express');
const crypto = require('crypto');
const { MongoClient } = require('mongodb');
const aws = require('aws-sdk');
require('dotenv').config();

const app = express();
app.use(express.json({ limit: '500mb' }));

const mongoClient = new MongoClient(process.env.MONGODB_URI);
const db = mongoClient.db('totallynotacloud');

const s3 = new aws.S3({
    endpoint: process.env.S3_ENDPOINT,
    accessKeyId: process.env.S3_ACCESS_KEY,
    secretAccessKey: process.env.S3_SECRET_KEY,
    s3ForcePathStyle: true
});

// Encryption utilities
class FileEncryption {
    static encryptInMemory(data, keyHash) {
        const key = crypto.scryptSync(keyHash, 'salt', 32);
        const iv = crypto.randomBytes(16);
        const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);
        
        let encrypted = cipher.update(data);
        encrypted = Buffer.concat([encrypted, cipher.final()]);
        
        const authTag = cipher.getAuthTag();
        return Buffer.concat([iv, authTag, encrypted]);
    }
    
    static decryptInMemory(encryptedData, keyHash) {
        const key = crypto.scryptSync(keyHash, 'salt', 32);
        const iv = encryptedData.slice(0, 16);
        const authTag = encryptedData.slice(16, 32);
        const encrypted = encryptedData.slice(32);
        
        const decipher = crypto.createDecipheriv('aes-256-gcm', key, iv);
        decipher.setAuthTag(authTag);
        
        let decrypted = decipher.update(encrypted);
        decrypted = Buffer.concat([decrypted, decipher.final()]);
        
        return decrypted;
    }
}

// Secure memory wipe (crypto context cleanup)
function secureWipe(buffer) {
    if (buffer && buffer.length) {
        buffer.fill(0);
    }
}

// Upload endpoint - receives encrypted file
app.post('/api/upload', async (req, res) => {
    try {
        const { fileId, fileName, mimeType, accessKeyHash, encryptedData } = req.body;
        
        if (!accessKeyHash || !encryptedData || !fileId) {
            return res.status(400).json({ error: 'Missing required fields' });
        }
        
        if (!isValidAccessKeyHash(accessKeyHash)) {
            return res.status(401).json({ error: 'Invalid access key' });
        }
        
        const buffer = Buffer.from(encryptedData, 'base64');
        
        // Store encrypted blob in S3
        const s3Params = {
            Bucket: process.env.S3_BUCKET,
            Key: `${accessKeyHash}/${fileId}`,
            Body: buffer,
            ServerSideEncryption: 'AES256'
        };
        
        await s3.upload(s3Params).promise();
        
        // Store metadata (encrypted at rest)
        const metadata = {
            fileId,
            fileName: crypto.randomBytes(16).toString('hex'),
            mimeType,
            accessKeyHash,
            uploadedAt: new Date(),
            expiresAt: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000),
            size: buffer.length
        };
        
        await db.collection('files').insertOne(metadata);
        
        // Clear sensitive data from memory
        buffer.fill(0);
        
        res.json({ success: true, fileId });
    } catch (error) {
        console.error('Upload error:', error);
        res.status(500).json({ error: 'Upload failed' });
    }
});

// Download endpoint - returns encrypted file
app.get('/api/download/:fileId', async (req, res) => {
    try {
        const { fileId } = req.params;
        const accessKeyHash = req.headers['x-access-key-hash'];
        
        if (!accessKeyHash) {
            return res.status(401).json({ error: 'Missing access key' });
        }
        
        const metadata = await db.collection('files').findOne({
            fileId,
            accessKeyHash
        });
        
        if (!metadata) {
            return res.status(404).json({ error: 'File not found' });
        }
        
        if (metadata.expiresAt < new Date()) {
            await db.collection('files').deleteOne({ fileId });
            await s3.deleteObject({
                Bucket: process.env.S3_BUCKET,
                Key: `${accessKeyHash}/${fileId}`
            }).promise();
            return res.status(410).json({ error: 'File expired' });
        }
        
        const data = await s3.getObject({
            Bucket: process.env.S3_BUCKET,
            Key: `${accessKeyHash}/${fileId}`
        }).promise();
        
        res.setHeader('Content-Type', metadata.mimeType);
        res.send(data.Body);
    } catch (error) {
        console.error('Download error:', error);
        res.status(500).json({ error: 'Download failed' });
    }
});

// List files for key
app.get('/api/files', async (req, res) => {
    try {
        const accessKeyHash = req.headers['x-access-key-hash'];
        
        if (!accessKeyHash) {
            return res.status(401).json({ error: 'Missing access key' });
        }
        
        const files = await db.collection('files')
            .find({ accessKeyHash })
            .toArray();
        
        const result = files.map(f => ({
            fileId: f.fileId,
            size: f.size,
            mimeType: f.mimeType,
            uploadedAt: f.uploadedAt,
            expiresAt: f.expiresAt
        }));
        
        res.json({ files: result });
    } catch (error) {
        console.error('List error:', error);
        res.status(500).json({ error: 'List failed' });
    }
});

// Delete file
app.delete('/api/files/:fileId', async (req, res) => {
    try {
        const { fileId } = req.params;
        const accessKeyHash = req.headers['x-access-key-hash'];
        
        if (!accessKeyHash) {
            return res.status(401).json({ error: 'Missing access key' });
        }
        
        const metadata = await db.collection('files').findOne({
            fileId,
            accessKeyHash
        });
        
        if (!metadata) {
            return res.status(404).json({ error: 'File not found' });
        }
        
        await s3.deleteObject({
            Bucket: process.env.S3_BUCKET,
            Key: `${accessKeyHash}/${fileId}`
        }).promise();
        
        await db.collection('files').deleteOne({ fileId });
        
        res.json({ success: true });
    } catch (error) {
        console.error('Delete error:', error);
        res.status(500).json({ error: 'Delete failed' });
    }
});

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date() });
});

function isValidAccessKeyHash(hash) {
    return /^[A-Za-z0-9+/]+=*$/.test(hash) && hash.length > 0;
}

app.listen(process.env.PORT || 3000, () => {
    console.log('Server running on port ' + (process.env.PORT || 3000));
});
```

## Security Configuration

### Memory Protection

```javascript
// Use secure memory libraries
const sodium = require('libsodium.js');

const secureMemory = Buffer.allocUnsafe(32);
sodium.randombytes_buf(secureMemory);

// Encrypt sensitive data in memory
const encrypted = sodium.crypto_secretbox(
    Buffer.from(data),
    nonce,
    key
);
```

### Storage Encryption

```bash
# MinIO setup with encryption
minio server --certs /path/to/certs /data

# Enable server-side encryption
mc admin config set minio/ kms:vault address=http://vault:8200
```

### TLS/HTTPS

```nginx
server {
    listen 443 ssl http2;
    server_name api.totallynotacloud.local;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    ssl_protocols TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header X-Forwarded-For $remote_addr;
    }
}
```

## Database Schema (MongoDB)

```javascript
db.createCollection('files', {
    validator: {
        $jsonSchema: {
            bsonType: 'object',
            required: ['fileId', 'accessKeyHash'],
            properties: {
                fileId: { bsonType: 'string' },
                fileName: { bsonType: 'string' },
                mimeType: { bsonType: 'string' },
                accessKeyHash: { bsonType: 'string' },
                size: { bsonType: 'long' },
                uploadedAt: { bsonType: 'date' },
                expiresAt: { bsonType: 'date' },
                deletedAt: { bsonType: ['date', 'null'] }
            }
        }
    }
});

db.files.createIndex({ accessKeyHash: 1 });
db.files.createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 });
db.files.createIndex({ createdAt: 1 }, { expireAfterSeconds: 7776000 });
```

## Deployment Checklist

- [ ] Generate RSA key pair for server
- [ ] Set up MinIO or S3 bucket with encryption
- [ ] Configure MongoDB with replication
- [ ] Enable TLS 1.3 only
- [ ] Set file expiration policy (default 90 days)
- [ ] Configure memory encryption at OS level
- [ ] Enable audit logging (no user data)
- [ ] Set up automatic backup encryption
- [ ] Configure rate limiting (100 req/min per key)
- [ ] Deploy with Docker/Kubernetes
- [ ] Set up monitoring without logging user data
- [ ] Configure CORS for trusted domains only

## Testing

```bash
# Test file upload
curl -X POST http://localhost:3000/api/upload \
  -H "Content-Type: application/json" \
  -d '{
    "fileId": "test-123",
    "fileName": "encrypted",
    "mimeType": "application/octet-stream",
    "accessKeyHash": "hash-value",
    "encryptedData": "base64-encoded-data"
  }'

# Test file download
curl http://localhost:3000/api/download/test-123 \
  -H "x-access-key-hash: hash-value"

# Test file list
curl http://localhost:3000/api/files \
  -H "x-access-key-hash: hash-value"
```

## Important Notes

1. **Private Key Security**: Never transmit private keys over the network. They stay on the client device only.
2. **Memory Wipe**: Ensure all sensitive data in RAM is wiped after use.
3. **No Logging**: Do not log any file contents, names, or access patterns.
4. **Ephemeral**: Files are automatically deleted after retention period.
5. **Key Rotation**: Implement key rotation for server encryption keys.
6. **Audit**: Log only infrastructure metrics, never user activity.
7. **Backup Encryption**: All backups must be encrypted with separate keys.
8. **Disaster Recovery**: Test recovery without exposing any data.

For questions or security concerns, submit responsibly at security@totallynotacloud.local
