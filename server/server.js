require('dotenv').config();
const express = require('express');
const crypto = require('crypto');
const { MongoClient } = require('mongodb');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json({ limit: '500mb' }));

let db;
const mongoClient = new MongoClient(process.env.MONGODB_URI || 'mongodb://localhost:27017');

mongoClient.connect().then(() => {
    db = mongoClient.db('totallynotacloud');
    console.log('Connected to MongoDB');
}).catch(err => {
    console.error('MongoDB connection error:', err);
    process.exit(1);
});

app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date() });
});

app.post('/api/upload', async (req, res) => {
    try {
        const { fileId, fileName, mimeType, accessKeyHash, encryptedData } = req.body;
        
        if (!accessKeyHash || !fileId) {
            return res.status(400).json({ error: 'Missing required fields' });
        }
        
        const expiresAt = new Date(Date.now() + (process.env.FILE_RETENTION_DAYS || 7) * 24 * 60 * 60 * 1000);
        
        const metadata = {
            fileId,
            fileName: fileName || 'file',
            mimeType: mimeType || 'application/octet-stream',
            accessKeyHash,
            uploadedAt: new Date(),
            expiresAt,
            size: encryptedData ? Buffer.from(encryptedData, 'base64').length : 0,
            downloadCount: 0
        };
        
        await db.collection('files').insertOne(metadata);
        
        res.json({ success: true, fileId, expiresAt });
    } catch (error) {
        console.error('Upload error:', error);
        res.status(500).json({ error: 'Upload failed' });
    }
});

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
            return res.status(410).json({ error: 'File expired' });
        }
        
        await db.collection('files').updateOne(
            { fileId },
            { $inc: { downloadCount: 1 } }
        );
        
        res.setHeader('Content-Type', metadata.mimeType);
        res.json({ fileId, size: metadata.size, mimeType: metadata.mimeType });
    } catch (error) {
        console.error('Download error:', error);
        res.status(500).json({ error: 'Download failed' });
    }
});

app.get('/api/files', async (req, res) => {
    try {
        const accessKeyHash = req.headers['x-access-key-hash'];
        
        if (!accessKeyHash) {
            return res.status(401).json({ error: 'Missing access key' });
        }
        
        const files = await db.collection('files')
            .find({ accessKeyHash })
            .sort({ uploadedAt: -1 })
            .toArray();
        
        const result = files.map(f => ({
            fileId: f.fileId,
            fileName: f.fileName,
            size: f.size,
            mimeType: f.mimeType,
            uploadedAt: f.uploadedAt,
            expiresAt: f.expiresAt,
            downloadCount: f.downloadCount
        }));
        
        res.json({ files: result });
    } catch (error) {
        console.error('List error:', error);
        res.status(500).json({ error: 'List failed' });
    }
});

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
        
        await db.collection('files').deleteOne({ fileId });
        
        res.json({ success: true });
    } catch (error) {
        console.error('Delete error:', error);
        res.status(500).json({ error: 'Delete failed' });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
