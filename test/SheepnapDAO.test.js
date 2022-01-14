const { assert } = require('chai');
const { default: Web3 } = require('web3');

const TokenFarm = artifacts.require("TokenFarm");
const DappToken = artifacts.require("DappToken");
const DaiToken = artifacts.require("DaiToken");

require('chai')
    .use(require('chai-as-promised'))
    .should()

contract('TokenFarm', ([owner, staker]) =>
{

});