const web3 = require('@solana/web3.js');
const fs = require('fs');
const path = require('path');

// Generate a new Keypair
const keypair = web3.Keypair.generate();

// Extract the secret key as a Uint8Array
const secretKey = new Uint8Array(keypair.secretKey);

// Optionally, save the keypair to a file
const outputPath = path.join(__dirname, 'solana-keypair.json');
fs.writeFileSync(outputPath, JSON.stringify(Array.from(secretKey)));

console.log('✅ Keypair generated!');
console.log('Public Key:', keypair.publicKey.toBase58());
console.log(`Keypair saved to ${outputPath}`);
