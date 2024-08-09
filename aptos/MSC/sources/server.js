const express = require('express');
const axios = require('axios');
const bodyParser = require('body-parser');
const { AptosClient, AptosAccount, AptosAPI } = require('aptos');
const app = express();
const port = 3000;

app.use(bodyParser.json());

const aptosClient = new AptosClient('https://fullnode.devnet.aptos.dev');
const api = new AptosAPI(aptosClient);

app.post('/generate-nft', async (req, res) => {
    try {
        const { userAddress, count } = req.body;
        
        // Call generative AI API
        const aiResponse = await axios.post('https://your-ai-api/generate', { count });
        const generatedArt = aiResponse.data;

        // Interact with Aptos smart contract
        const tx = await api.createTransaction({
            // Transaction details to mint NFT using Move smart contract
        });

        res.status(200).json({ message: 'NFTs minted successfully', art: generatedArt });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Failed to generate and mint NFTs' });
    }
});

app.listen(port, () => {
    console.log(`Backend service listening at http://localhost:${port}`);
});
