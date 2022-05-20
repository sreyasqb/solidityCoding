// deploy code will go here
const HDWalletProvider = require("@truffle/hdwallet-provider");
const Web3=require('web3');
const {interface,bytecode}=require('./compile');
const {mnemonic,apiKey}=require('./credentials');

const provider=new HDWalletProvider(
    mnemonic,
    apiKey
);

const web3= new Web3(provider);

const deploy = async ()=>{
    const accounts=await web3.eth.getAccounts();

    console.log(`deploying from ${accounts[0]}`);

    const result = await new web3.eth.Contract(JSON.parse(interface))
        .deploy({data:bytecode,arguments:['Hi There!']})
        .send({gas:'1000000',from:accounts[0]});
        
    console.log(`Deploying to the address ${result.options.address}`);
    provider.engine.stop();
};

deploy();