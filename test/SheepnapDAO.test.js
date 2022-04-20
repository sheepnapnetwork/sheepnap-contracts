const { assert } = require('chai');
const { default: Web3 } = require('web3');

const WoolToken = artifacts.require("WoolToken");
const SheepnapDAO = artifacts.require("SheepnapDAO");
const Booken = artifacts.require("Booken");
const Property = artifacts.require("Booken");
const Badge = artifacts.require("Badge");

require('chai')
    .use(require('chai-as-promised'))
    .should()

contract('SheepnapDAO', ([owner, stakerOne, stakerTwo, propertyOwner, badgeBuyer ]) =>
{
    before(async() => 
    {
        woolToken = await WoolToken.new();
        booken = await Booken.new();
        badge = await Badge.new();

        sheepnapDAO = await SheepnapDAO.new(woolToken.address, badge.address);
        propertyContract = await Property.new();
        var weiToTransfer = web3.utils.toWei('1000', 'ether')
        
    });
});