// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    // State variables
    address public owner;
    string public title;
    string public description;
    uint256 public fundingGoal;
    uint256 public deadline;
    uint256 public currentFunding;
    mapping(address => uint256) public contributions;
    address[] public contributors;

    // Events
    event Contribute(address indexed contributor, uint256 amount);
    event Withdraw(address indexed contributor, uint256 amount);
    event ProjectFunded(uint256 amount);

    // Constructor
    constructor(string memory _title, string memory _description, uint256 _fundingGoal, uint256 _durationInDays) {
        owner = msg.sender;
        title = _title;
        description = _description;
        fundingGoal = _fundingGoal * 1 ether;
        deadline = block.timestamp + (_durationInDays * 1 days);
    }

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyBeforeDeadline() {
        require(block.timestamp < deadline, "The deadline has passed");
        _;
    }

    modifier onlyAfterDeadline() {
        require(block.timestamp >= deadline, "The deadline has not passed yet");
        _;
    }

    // Functions
    function contribute() public payable onlyBeforeDeadline {
        require(msg.value > 0, "Contribution amount must be greater than 0");

        if (contributions[msg.sender] == 0) {
            contributors.push(msg.sender);
        }

        contributions[msg.sender] += msg.value;
        currentFunding += msg.value;

        emit Contribute(msg.sender, msg.value);
    }

    function withdraw() public onlyAfterDeadline {
        require(currentFunding < fundingGoal, "The project is already funded");

        uint256 contribution = contributions[msg.sender];
        require(contribution > 0, "You have not contributed to the project");

        contributions[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: contribution}("");
        require(success, "Withdraw failed");

        emit Withdraw(msg.sender, contribution);
    }

    function fundProject() public onlyAfterDeadline {
        require(currentFunding >= fundingGoal, "The funding goal has not been reached");

        (bool success, ) = payable(owner).call{value: currentFunding}("");
        require(success, "Funding failed");

        emit ProjectFunded(currentFunding);
    }

    function getProjectDetails() public view returns (string memory, string memory, uint256, uint256, uint256, uint256) {
        return (title, description, fundingGoal, deadline, currentFunding, contributors.length);
    }

    function getContributorDetails(address _contributor) public view returns (uint256) {
        return contributions[_contributor];
    }

    function getContributors() public view returns (address[] memory) {
        return contributors;
    }
}