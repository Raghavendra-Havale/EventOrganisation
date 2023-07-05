//SPDX-License-Identifier: Unlicense
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";



contract EventContract {
 struct Event{
   address organizer;
   string name;
   uint date; //0 1 2
   uint price;
   uint ticketCount;  //1 sec  0.5 sec
   uint ticketRemain;
 }


 mapping(uint=>Event) public events;
 mapping(address =>mapping(uint=>uint)) public tickets;
 uint public nextId;
 address organiser;
 address eventContract;

 constructor(){
   organiser=msg.sender;
 }

modifier onlyAdmin(){
  require(msg.sender==organiser);
  _;
}
 
 function setEventContract(address _contract)public onlyAdmin{
    eventContract=_contract;
  }


 function createEvent(string memory _name,uint _date,uint _price,uint _ticketCount) external onlyAdmin{
   require(_date>block.timestamp,"You can organize event for future date");
   require(_ticketCount>0,"You can organize event only if you create more than 0 tickets");


   events[nextId] = Event(msg.sender,_name,_date,_price,_ticketCount,_ticketCount);
   nextId++;
 }


 function buyTicket(uint _id,uint _quantity) external payable{
   require(events[_id].date!=0,"Event does not exist");
   require(events[_id].date>block.timestamp,"Event has already occured");
  //  Event storage _event = events[_id];
   require(msg.value==(events[_id].price*_quantity),"Ethere is not enough");
   require(events[_id].ticketRemain>=_quantity,"Not enough tickets");
   events[_id].ticketRemain-=_quantity;
   tickets[msg.sender][_id]+=_quantity;
   MCSTAN mcstan=MCSTAN(eventContract);
   for(uint i=1;i<=_quantity;i++){
     mcstan.safeMint(msg.sender);
   }
  
}

  
}

contract MCSTAN is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("MCSTAN", "MCS") {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://bafybeihq26gxhdq7kzjd4sjl5ww4autf7kgroujbs274xbzegkebe2czkm/";
    }

    function safeMint(address to) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }
}
