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
    let sheepnapDAO, woolToken, booken, property, badge;

    before(async() => 
    {
        woolToken = await WoolToken.new();
        booken = await Booken.new();
        badge = await Badge.new();

        sheepnapDAO = await SheepnapDAO.new(woolToken.address, badge.address);
        propertyContract = await Property.new();
        var weiToTransfer = web3.utils.toWei('1000', 'ether')

        //user distribution
        await woolToken.transfer(stakerOne, weiToTransfer);
        await woolToken.transfer(stakerTwo, weiToTransfer);
        
    });

    describe('Initial stakers distribution', async() => 
    {
        it('Initial distribution is correct', async() => 
        {
            var stakerOneBalance = await woolToken.balanceOf(stakerOne);
            assert.equal(stakerOneBalance, web3.utils.toWei('1000'));
        });
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
            
            assert.equal(amountForRequest, 100*10**18);
            assert.equal(approvalDaysToVote, 10);
            assert.equal(approvalPercentage, 50)
            assert.equal(minimalPercentageVoters, 30);
        });
    });

    describe('Staking', async() => {

        it('Shouldnt allow 0 staking amount', async()=>
        {
            //TODO : how to expect exceptions
        });

        it('Initial staking is correct', async() =>
        {
            var stakingAmount = web3.utils.toWei('100');
            var stakingAmountStakerTwo = web3.utils.toWei('300');

            await woolToken
            .approve(sheepnapDAO.address, stakingAmount, 
                { from : stakerOne });

            await sheepnapDAO.stake(stakingAmount, 
                { from : stakerOne });

            await woolToken
            .approve(sheepnapDAO.address, stakingAmountStakerTwo, 
                { from : stakerTwo });

            await sheepnapDAO.stake(stakingAmountStakerTwo, 
                { from : stakerTwo });
            
            //Checking staking balances
            var stakingAmountResult = await sheepnapDAO.getStakeAmount({ from : stakerOne });
            var stakingAmountTwoResult = await sheepnapDAO.getStakeAmount({ from : stakerTwo });
            
            assert.equal(stakingAmountResult.toString(), web3.utils.toWei('100'));
            assert.equal(stakingAmountTwoResult.toString(), web3.utils.toWei('300'));
        });
    });

    describe('Property registration and approval request', async() => {

        it('Property registration', async() =>
        {   
            var amount = web3.utils.toWei('100');
            
            await woolToken
            .approve(sheepnapDAO.address, amount, 
                { from : propertyOwner });

            await woolToken.transfer(propertyOwner, amount);

            await sheepnapDAO.approvalRequest(propertyContract.address, 
                { from : propertyOwner });
            
            var activeVoting = await sheepnapDAO.getPropertyActiveVoting(propertyContract.address);
            assert.equal(activeVoting, true);
        });

    });

    describe('Property voting', async() => 
    {
        it('Staker can vote yes', async() =>
        {
            await sheepnapDAO.vote(propertyContract.address, true, 
                { from : stakerOne });

            var approvalRequest = await sheepnapDAO
                .getApprovalRequestInfo(propertyContract.address);

            assert.equal(approvalRequest.totalVoters, '1');
            assert.equal(approvalRequest.totalYes, '1');
        });
    });

    describe('Badge is minted correctly', async () =>
    {
        it('Badge can buy correctly', async() =>
        {
            var idNFT = 354;
            var amountPrice = web3.utils.toWei('200');
            var initialSheepnapDAOTokenAmount = await woolToken.balanceOf(sheepnapDAO.address);
    
            await woolToken.transfer(badgeBuyer, amountPrice);
    
            await woolToken
            .approve(sheepnapDAO.address, amountPrice, 
                { from : badgeBuyer });
            await badge.transferOwnership(sheepnapDAO.address);
            await sheepnapDAO.addNewBadgePrice(idNFT, amountPrice, { from : owner });
            await sheepnapDAO.mintForBuy(idNFT, { from : badgeBuyer });
    
            //Assert
            var expectedBalanceOfBuyer = await woolToken.balanceOf(badgeBuyer);
            var expectedBalanceNFTOfBuyer = await badge.balanceOf(badgeBuyer, idNFT);
            var expectedBalanceTokenOfSheepnapDAO = await woolToken.balanceOf(sheepnapDAO.address);

            assert.equal(expectedBalanceOfBuyer, 0);
            assert.equal(expectedBalanceNFTOfBuyer, 1);
            
            var initialAmountPlusNFTValue = parseInt(web3.utils.fromWei(initialSheepnapDAOTokenAmount)) +  parseInt(web3.utils.fromWei(amountPrice));
            assert.equal(web3.utils.fromWei(expectedBalanceTokenOfSheepnapDAO),initialAmountPlusNFTValue.toString());
    
        });
       
    });

});