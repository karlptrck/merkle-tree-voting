pragma solidity ^0.5.0;

contract Voting {
    bytes32 eligibleVotersMerkleRoot;
    mapping(address => bool) voted;
    uint256 yesVotes;
    uint256 noVotes;

    constructor(bytes32 eligibleVotersMerkleRoot_) public {
        eligibleVotersMerkleRoot = eligibleVotersMerkleRoot_;
    }

    function leafHash(address leaf) private pure returns(bytes32) {
        return keccak256(abi.encodePacked(uint8(0x00), leaf));
    }

    function nodeHash(bytes32 left, bytes32 right) private pure returns(bytes32) {
        return keccak256(abi.encodePacked(uint8(0x01), left, right));
    }

    function vote(uint256 path, bytes32[] memory witnesses, bool myVote) public {
        require(!voted[msg.sender], "already voted");
        voted[msg.sender] = true;

        if (myVote) yesVotes++;
        else noVotes++;

        bytes32 node = leafHash(msg.sender);
        for(uint16 i = 0; i < witnesses.length; i++){
            if((path & 0x01) == 1){
                node = nodeHash(witnesses[i], node);
            }else{
                node = nodeHash(node, witnesses[i]);
            }
            path /= 2;
        }
        
        require(node == eligibleVotersMerkleRoot, "You are not eligible to cast vote.");
        
    }
}
