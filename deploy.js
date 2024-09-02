require('dotenv').config();
const { Alchemy, Network } = require('alchemy-sdk');
const {Web3} = require('web3');
const fs = require('fs');
const solc = require('solc');

const settings = {
    apiKey: process.env.ALCHEMY_API_KEY,
    network: Network.ETH_SEPOLIA,
};

const alchemy = new Alchemy(settings);
const web3 = new Web3(alchemy.web3Provider);

const account = web3.eth.accounts.privateKeyToAccount(process.env.PRIVATE_KEY);
web3.eth.accounts.wallet.add(account);
web3.eth.defaultAccount = account.address;

const contractPath = './EmployeePayment.sol';
const contractSource = fs.readFileSync(contractPath, 'utf8');

const input = {
    language: 'Solidity',
    sources: {
        'EmployeePayment.sol': {
            content: contractSource,
        },
    },
    settings: {
        outputSelection: {
            '*': {
                '*': ['*'],
            },
        },
    },
};

const output = JSON.parse(solc.compile(JSON.stringify(input)));

// Check for compilation errors
if (output.errors) {
    output.errors.forEach(err => {
        console.error(err.formattedMessage);
    });
    throw new Error('Compilation failed');
}

const compiledContract = output.contracts['EmployeePayment.sol'].EmployeePayment;
const contractABI = compiledContract.abi;
fs.writeFileSync('EmployeePaymentABI.json', JSON.stringify(contractABI, null, 2));

const contract = new web3.eth.Contract(contractABI);

async function deploy() {
    const deployTx = contract.deploy({
        data: compiledContract.evm.bytecode.object,
    });

    const deployedContract = await deployTx.send({
        from: account.address,
        gas: 1500000,
        gasPrice: '30000000000',
    });

    console.log('Contract deployed at address:', deployedContract.options.address);
    fs.writeFileSync('EmployeePaymentAddress.txt', deployedContract.options.address);
}

deploy().catch(console.error);