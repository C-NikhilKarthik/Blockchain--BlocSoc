// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    // State variables to store campaign details
    address public owner;
    uint256 public goal;
    uint256 public endTime;
    uint256 public totalFunds;
    address[] public contributors;

    // Mapping to track individual contributions
    mapping(address => uint256) public contributions;

    // Enum to define campaign states
    enum CampaignState { Ongoing, Failed, Successful }
    CampaignState public state;

    // Constructor to initialize the contract
    constructor(uint256 _goal, uint256 _durationInDays) {
        owner = msg.sender;
        goal = _goal * 1 ether; // Convert goal to wei
        endTime = block.timestamp + (_durationInDays * 1 days);
        state = CampaignState.Ongoing;
        totalFunds = 0;
    }

// Function to allow contributions
function contribute() external payable {
    require(state == CampaignState.Ongoing, "Campaign is not ongoing");
    require(block.timestamp < endTime, "Campaign has ended");
    require(msg.value > 0, "Contribution amount must be greater than 0");

    // Transfer the contributed Ether from the sender to the contract
    address contributor = msg.sender;
    uint256 value = msg.value;

    // Update the contributor's balance
    contributions[contributor] += value;
    totalFunds += value;

    // Add the contributor to the list if not already added
    if (contributions[contributor] == value) {
        contributors.push(contributor);
    }

    // Check if the campaign goal is reached
    if (totalFunds >= goal) {
        state = CampaignState.Successful;
    }
}


    // Function for the owner to withdraw funds (if the campaign is successful)
    function withdrawFunds() external {
        require(msg.sender == owner, "Only the owner can withdraw funds");
        require(state == CampaignState.Successful, "Campaign is not successful");

        payable(owner).transfer(address(this).balance);
    }

    // Function for contributors to get a refund (if the campaign fails)
    function refundContribution() external {
        require(state == CampaignState.Failed, "Campaign is not failed");
        require(contributions[msg.sender] > 0, "No contribution to refund");

        uint256 refundAmount = contributions[msg.sender];
        contributions[msg.sender] = 0;

        payable(msg.sender).transfer(refundAmount);
    }

    // Function to check if the campaign has failed
    function checkCampaignStatus() external {
        require(block.timestamp >= endTime, "Campaign is still ongoing");
        require(state == CampaignState.Ongoing, "Campaign is not ongoing");

        if (totalFunds < goal) {
            state = CampaignState.Failed;
        }
    }

    function getFundsCollected() external view returns (uint256) {
        return totalFunds;
    }


    // Function to get all contributors
    function getContributors() external view returns (address[] memory) {
        return contributors;
    }
}
