// SPDX-License-Identifier: GPL-3.0
//A smart contract to organise events
pragma solidity ^0.5.0;
contract EventOrganisation{
    address organiser;
    //To set contract deployer as organiser
    constructor() public {
        organiser=msg.sender;
    }

    //To restrict any function access to organiser
    modifier OnlyOrganiser(){
        require(msg.sender==organiser,"Unauthorised operation");
        _;
    }
    //Event details
    struct Event{
        string eventName;
        uint eventTime;
        uint eventPrice;
        string eventLocation;
        uint tickets;
        uint remainingTic;
    }

    //Attendee details
    struct Attendee{
        string bookingName;
        address bookingAddress;
        uint noOfTickets;
        string eventName;
    }

    mapping(string=>Event) public Events;
    mapping(address=>Attendee) public Attendees;

    //To schedule an event
    function ScheduleEvent(string memory _eventName,uint _eventPrice,string memory _eventLocation,uint _eventTime,uint _tickets) public OnlyOrganiser{
        require(_eventTime>=block.timestamp,"Invalid");
        Events[_eventName]=Event(_eventName,_eventTime,_eventPrice,_eventLocation,_tickets,_tickets);
        }

    //To book a ticket for the event
    function bookTicket(string memory _bookingName,address _bookingAddress,uint _noOfTickets,string memory _eventName) public payable {
        require(Events[_eventName].eventTime!=0,"Event does not exist");
        require(block.timestamp<Events[_eventName].eventTime,"Event is over");
        require(Events[_eventName].remainingTic>_noOfTickets,"Insufficient tickets");
        require(msg.value==(Events[_eventName].eventPrice*_noOfTickets),"Insufficient funds");
        Attendees[_bookingAddress]=Attendee(_bookingName,msg.sender,_noOfTickets,_eventName);
        Events[_eventName].remainingTic-=Attendees[_bookingAddress].noOfTickets;
      }
}