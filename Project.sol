// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearnToEarn {

    // Mapping of user address to their fractional ownership of study guides
    mapping(address => mapping(uint256 => uint256)) public ownership; // user -> studyGuideId -> ownershipPercentage
    mapping(uint256 => uint256) public totalShares; // studyGuideId -> total shares (percentage = 100)

    struct StudyGuide {
        string title;
        string content;
        uint256 price; // price to access the study guide
        uint256 shares; // total fractional shares of this guide
    }

    StudyGuide[] public studyGuides;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    event StudyGuideCreated(uint256 indexed studyGuideId, string title, uint256 price, uint256 shares);
    event OwnershipTransferred(uint256 indexed studyGuideId, address indexed newOwner, uint256 shares);

    constructor() {
        owner = msg.sender;
    }

    // Create a new study guide
    function createStudyGuide(string memory title, string memory content, uint256 price, uint256 shares) public onlyOwner {
        require(shares > 0, "Shares should be greater than zero");

        StudyGuide memory newGuide = StudyGuide({
            title: title,
            content: content,
            price: price,
            shares: shares
        });

        uint256 studyGuideId = studyGuides.length;
        studyGuides.push(newGuide);
        totalShares[studyGuideId] = shares;

        emit StudyGuideCreated(studyGuideId, title, price, shares);
    }

    // Allow users to buy fractional ownership in a study guide
    function buyOwnership(uint256 studyGuideId, uint256 percentage) public payable {
        require(studyGuideId < studyGuides.length, "Study guide not found");
        StudyGuide storage guide = studyGuides[studyGuideId];

        require(msg.value == guide.price * percentage / 100, "Incorrect payment amount");
        require(ownership[msg.sender][studyGuideId] + percentage <= 100, "You cannot own more than 100% of a guide");

        ownership[msg.sender][studyGuideId] += percentage;
        totalShares[studyGuideId] -= percentage;

        payable(owner).transfer(msg.value);

        emit OwnershipTransferred(studyGuideId, msg.sender, percentage);
    }

    // Get details of a study guide
    function getStudyGuide(uint256 studyGuideId) public view returns (string memory, string memory, uint256, uint256) {
        require(studyGuideId < studyGuides.length, "Study guide not found");
        StudyGuide memory guide = studyGuides[studyGuideId];
        return (guide.title, guide.content, guide.price, guide.shares);
    }

    // Get the ownership of a user in a study guide
    function getOwnership(address user, uint256 studyGuideId) public view returns (uint256) {
        return ownership[user][studyGuideId];
    }
}