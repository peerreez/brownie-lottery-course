// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract Lottery is Ownable, VRFConsumerBase {
    address payable[] public players;
    uint256 public usdEnterFee;
    // Vrf variables
    uint256 public fee;
    bytes32 public keyhash;
    // priceFeed
    AggregatorV3Interface internal ethUsdPriceFeed;
    // after lottery
    address payable public recentWinner;
    uint256 public randomness;
    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }

    // OPEN -> 0
    // CLOSE -> 1
    // CALCULATING_WINNER -> 2

    LOTTERY_STATE public lottery_state;

    // events
    event RequestRandomness(bytes32 requestId);

    constructor(
        address _priceFeedAddress,
        address _vrfCoordinator,
        address _linkToken,
        uint256 _fee,
        bytes32 _keyhash
    ) public VRFConsumerBase(_vrfCoordinator, _linkToken) {
        usdEnterFee = 50 * (10 ** 18);
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        lottery_state = LOTTERY_STATE.CLOSED;
        fee = _fee;
        keyhash = _keyhash;
    }

    function enter() public payable {
        // $50
        require(lottery_state == LOTTERY_STATE.OPEN, "Lottery is not open!");
        require(msg.value >= getEntranceFee(), "Not enough ETH!");
        players.push(msg.sender);
    }

    function getEntranceFee() public view returns (uint256) {
        (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();
        uint256 adjustedPrice = uint256(price) * 10 ** 10;
        // $50, $2000 /ETH
        // 50 / 2000
        // 50 * 10000 / 2000
        uint256 costToEnter = (usdEnterFee * 10 ** 18) / adjustedPrice;
        return costToEnter;
    }

    function startLottery() public onlyOwner {
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "Lottery is already open!"
        );
        lottery_state = LOTTERY_STATE.OPEN;
    }

    function endLottery() public onlyOwner {
        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
        bytes32 requestId = requestRandomness(keyhash, fee);
        emit RequestRandomness(requestId);
    }

    function fulfillRandomness(
        bytes32 _requestId,
        uint256 _randomness
    ) internal override {
        require(
            lottery_state == LOTTERY_STATE.CALCULATING_WINNER,
            "Lottery is not open!"
        );
        require(_randomness > 0, "Randomness not found");
        uint256 indexOfWinner = _randomness % players.length;
        recentWinner = players[indexOfWinner];
        // pagarle al ganador
        recentWinner.transfer(address(this).balance);
        // Reset lottery
        players = new address payable[](0);
        lottery_state = LOTTERY_STATE.CLOSED;
        randomness = _randomness;
    }

    function getLotteryState() public view returns (uint256) {
        return uint256(lottery_state);
    }

    function getRecentWinner() public view returns (address) {
        return recentWinner;
    }
}
