// SPDX License Identifier : MIT
pragma solidity >=0.7.0 <0.9.0;
interface IERC721 {
    function transferFrom(
        address from,
        address to,
        uint NFTId
    )external;
}
contract EnglishAuction{
    IERC721 public NFT;
    uint public NFTId;
    address public highestBidder;
    uint public highestBid;
    bool public started;
    bool public ended;
    mapping (address=>uint) bids;
    address payable public seller;
    uint32 public endAt;
    event Start();
    event Bid(uint _highBid,address indexed _bidder);
    event Withdrawl (address account, uint _depo);
    event End();

    constructor(uint startbid,address _NFT,uint _NFTId ){
        seller = payable(msg.sender);
        highestBid = startbid;
        started = true;
        NFTId=_NFTId;
    }
    function start( )  external {
        require(msg.sender==seller);
        require(!started);
        started=true;
        endAt = uint32(block.timestamp+60);
         NFT.transferFrom(seller,address(this),NFTId);
         emit Start();

    }
    function bid() external payable {
        require(started);
        require(block.timestamp<endAt);
        require(msg.value>highestBid);
        if(highestBidder!=address(0)){
            bids[highestBidder]+=highestBid;
        }
        highestBid=msg.value;
        highestBidder=msg.sender;
        emit Bid(highestBid,highestBidder);
    }
    function withdrawBid() external {
        uint deposited =  bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(deposited);
        emit Withdrawl (msg.sender,deposited);
    }
    function end() external {
        require(started);
        require(ended);
        require(block.timestamp>=endAt);
        ended=true;
        if(highestBidder !=address(0)){
        NFT.transferFrom(address(this),highestBidder,NFTId);
        
        seller.transfer(highestBid);}
        else{
            NFT.transferFrom(address(this),seller,NFTId);
        }
        emit End();
    }
}