const { assert } = require('chai');
const { default: Web3 } = require('web3');

const WoolToken = artifacts.require("WoolToken");
const SheepnapDAO = artifacts.require("SheepnapDAO");
const Booken = artifacts.require("Booken");
const Property = artifacts.require("Booken");

require('chai')
    .use(require('chai-as-promised'))
    .should()

contract('SheepnapDAO', ([owner, staker]) =>
{
    let sheepnapDAO, woolToken, booken, property;

    before(async() => 
    {
        woolToken = await WoolToken.new();
        booken = await Booken.new();
        sheepnapDAO = await SheepnapDAO.new(woolToken.address);

        //woolToken.tra
    });

    describe('Initial Wool Token mint', async() => {

        it('Wool token has correct symbol and name', async() => 
        {
            var tokenName = await woolToken.name();
            assert.equal(tokenName, "WOOL");
        });
    });

    describe('Initial SheepnapDao Deploy', async() => 
    {
        it('Inital parameters are correct', async() => 
        {
            var amountForRequest = await sheepnapDAO.getTokenAmountForApprovalRequest();
            var approvalDaysToVote = await sheepnapDAO.getApprovalRequestDaysToVote();
            var approvalPercentage = await sheepnapDAO.getApprovalPercentage();
            var minimalPercentageVoters = await sheepnapDAO.getMinimalPercentageVoters();
            
            assert.equal(amountForRequest, 100);
            assert.equal(approvalDaysToVote, 10);
            assert.equal(approvalPercentage, 50)
            assert.equal(minimalPercentageVoters, 30);
        });
    });

    describe('', async() => {


    });



});