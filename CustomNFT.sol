// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CustomNFT {
    string public name = "CustomNFT";
    string public symbol = "CNFT";
    uint256 public totalSupply;
    uint256 public constant MAX_SUPPLY = 100;

    mapping(uint256 => address) public owners;
    mapping(address => uint256) public balances;
    mapping(uint256 => address) public tokenApprovals;
    mapping(address => mapping(address => bool)) public operatorApprovals;
    mapping(address => bool) public hasMinted;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    modifier onlyOwner(uint256 tokenId) {
        require(owners[tokenId] == msg.sender, "Not token owner");
        require(owners[tokenId] != address(0), "Token doesn't exist");
        _;
    }

    function mint() external {
        require(totalSupply < MAX_SUPPLY, "Max supply reached");
        require(!hasMinted[msg.sender], "Already minted");

        uint256 tokenId = totalSupply + 1;
        owners[tokenId] = msg.sender;
        balances[msg.sender] += 1;
        hasMinted[msg.sender] = true;
        totalSupply++;

        emit Transfer(address(0), msg.sender, tokenId);
    }

    function burn(uint256 tokenId) external onlyOwner(tokenId) {
        balances[msg.sender] -= 1;
        delete owners[tokenId];
        delete tokenApprovals[tokenId];
        totalSupply--;

        emit Transfer(msg.sender, address(0), tokenId);
    }

    function approve(address to, uint256 tokenId) external {
        require(owners[tokenId] != address(0), "Token doesn't exist");
        require(owners[tokenId] == msg.sender, "Not token owner");

        tokenApprovals[tokenId] = to;
        emit Approval(msg.sender, to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) external {
        operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedOrOwner(address spender, uint256 tokenId) public view returns (bool) {
        address owner = owners[tokenId];
        require(owner != address(0), "Token doesn't exist");
        return (
            spender == owner ||
            tokenApprovals[tokenId] == spender ||
            operatorApprovals[owner][spender]
        );
    }

    function transferFrom(address from, address to, uint256 tokenId) external {
        require(owners[tokenId] != address(0), "Token doesn't exist");
        require(to != address(0), "Cannot transfer to zero address");
        require(isApprovedOrOwner(msg.sender, tokenId), "Not approved");
        require(from == owners[tokenId], "Incorrect owner");

        owners[tokenId] = to;
        balances[from] -= 1;
        balances[to] += 1;

        delete tokenApprovals[tokenId];
        emit Transfer(from, to, tokenId);
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = owners[tokenId];
        require(owner != address(0), "Token doesn't exist");
        return owner;
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Invalid address");
        return balances[owner];
    }
}