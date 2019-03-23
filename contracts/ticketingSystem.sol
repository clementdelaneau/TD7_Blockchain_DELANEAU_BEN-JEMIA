pragma solidity ^0.5.0;


contract ticketingSystem {

	struct Artist{
		bytes32 name;
		uint artistCategory;
		address payable owner;
		uint totalTicketSold;
	}

	uint NextIdArtist;
	uint NextIdVenue;
	uint NextIdConcert;
	uint NextIdTicket;

	constructor() public
	{
	 NextIdArtist=1;
	 NextIdVenue=1;
	 NextIdConcert=1;
	 NextIdTicket=1;

	}



	 mapping  (uint => Artist) public artistsRegister;



	function createArtist(bytes32  _name, uint _artistCategory) public {

		artistsRegister[NextIdArtist].name=_name;
		artistsRegister[NextIdArtist].artistCategory=_artistCategory;
		artistsRegister[NextIdArtist].owner=msg.sender;
		NextIdArtist++;
	}


	function modifyArtist(uint _idArtist,bytes32 _name, uint _artistCategory, address payable _owner) public
	{
		require(artistsRegister[_idArtist].owner==msg.sender);
		artistsRegister[_idArtist].name=_name;
		artistsRegister[_idArtist].artistCategory=_artistCategory;
		artistsRegister[_idArtist].owner=_owner;

	}
	

	struct Venue{

		bytes32 name;
		uint capacity;
		uint standardComission;
		address payable owner;
	}

	mapping (uint => Venue) public venuesRegister;

	function createVenue(bytes32 _name, uint _capacity,uint _standardComission) public
	{
		venuesRegister[NextIdVenue].name=_name;
		venuesRegister[NextIdVenue].capacity=_capacity;
		venuesRegister[NextIdVenue].standardComission=_standardComission;
		venuesRegister[NextIdVenue].owner=msg.sender;
		NextIdVenue++;

	}


	function modifyVenue(uint _idVenue,bytes32 _name, uint _capacity, uint _standardComission,address payable _owner) public
	{
		require(venuesRegister[_idVenue].owner==msg.sender);
		venuesRegister[_idVenue].name=_name;
		venuesRegister[_idVenue].capacity=_capacity;
		venuesRegister[_idVenue].standardComission=_standardComission;
		venuesRegister[_idVenue].owner=_owner;
	}



struct Concert{
  uint artistId;
  uint venueId;
  uint concertDate;
  uint nbrTickets;
  uint concertPrice;
  address payable owner;
  bool validatedByArtist;
  bool validatedByVenue;
  uint totalSoldTicket;
  uint totalMoneyCollected;

  }

  mapping (uint=> Concert) public concertsRegister;

  function createConcert(uint _artistId, uint _venueId, uint _concertDate, uint _concertPrice)
  public
  returns (uint concertNumber)
  {
    require(_concertDate >= now);
    require(artistsRegister[_artistId].owner != address(0));
    require(venuesRegister[_venueId].owner != address(0));
    concertsRegister[NextIdConcert].totalSoldTicket=0;
    concertsRegister[NextIdConcert].totalMoneyCollected=0;
    concertsRegister[NextIdConcert].concertDate = _concertDate;
    concertsRegister[NextIdConcert].artistId = _artistId;
    concertsRegister[NextIdConcert].venueId = _venueId;
    concertsRegister[NextIdConcert].concertPrice = _concertPrice;
    validateConcert(NextIdConcert);
    concertNumber = NextIdConcert;
    NextIdConcert +=1;
  }


function validateConcert(uint _concertId)
  public
  {
    require(concertsRegister[_concertId].concertDate >= now);
    if (venuesRegister[concertsRegister[_concertId].venueId].owner == msg.sender)
    {
      concertsRegister[_concertId].validatedByVenue = true;
    }
    if (artistsRegister[concertsRegister[_concertId].artistId].owner == msg.sender)
    {
      concertsRegister[_concertId].validatedByArtist = true;
    }
  }


  struct Ticket{
  	address payable owner;
  	bool isAvailable;
  	uint concertId;
  	bool isAvailableForSale;
  	uint amountPaid;
  	uint salePrice;
  }

  mapping (uint => Ticket) public ticketsRegister;
  

 function emitTicket(uint _concertId, address payable _ticketOwner) public
  {
  	require(msg.sender==artistsRegister[concertsRegister[_concertId].artistId].owner);
  	
  	ticketsRegister[NextIdTicket].concertId=_concertId;
  	ticketsRegister[NextIdTicket].isAvailable=true;
  	ticketsRegister[NextIdTicket].owner=_ticketOwner;
  	ticketsRegister[NextIdTicket].isAvailableForSale=true;
  	ticketsRegister[NextIdTicket].amountPaid=concertsRegister[_concertId].concertPrice;
  	concertsRegister[_concertId].totalSoldTicket++;
  	NextIdTicket++;

  }

  function useTicket(uint _ticketId) public
  {
  	require(msg.sender==ticketsRegister[_ticketId].owner);
  	require(concertsRegister[ticketsRegister[_ticketId].concertId].concertDate>now);
  	require(concertsRegister[ticketsRegister[_ticketId].concertId].concertDate<now+24*60*60);
  	require(concertsRegister[ticketsRegister[_ticketId].concertId].validatedByArtist==true);
  	require(concertsRegister[ticketsRegister[_ticketId].concertId].validatedByVenue==true);
  	ticketsRegister[_ticketId].isAvailable=false;
  	ticketsRegister[_ticketId].owner=address(0);  	

  }


  function buyTicket(uint _concertId)  payable public
  {

  	require (msg.value==concertsRegister[_concertId].concertPrice);
  	concertsRegister[_concertId].totalSoldTicket++;
  	concertsRegister[_concertId].totalMoneyCollected+=msg.value;
  	ticketsRegister[NextIdTicket].owner=msg.sender;
  	ticketsRegister[NextIdTicket].amountPaid=msg.value;
  	ticketsRegister[NextIdTicket].concertId=_concertId;
  	ticketsRegister[NextIdTicket].isAvailable=true;
  	ticketsRegister[NextIdTicket].isAvailableForSale=false;
  	NextIdTicket++;

  }


  function transferTicket(uint _ticketId, address payable _newOwner) public
  {
  	require(msg.sender==ticketsRegister[_ticketId].owner);
  	ticketsRegister[_ticketId].owner=_newOwner;
  }


  function cashOutConcert(uint _concertId, address payable _cashOutAddress)  public{
  		require(concertsRegister[_concertId].concertDate<now);
  		require(msg.sender==artistsRegister[concertsRegister[_concertId].artistId].owner);

  		uint totalTicketSale = 2*concertsRegister[_concertId].concertPrice;
  		uint venueShare = totalTicketSale * venuesRegister[concertsRegister[_concertId].venueId].standardComission / 10000;
  		uint artistShare= totalTicketSale - venueShare;

  		venuesRegister[concertsRegister[_concertId].venueId].owner.transfer(venueShare);
  		_cashOutAddress.transfer(artistShare);

  		artistsRegister[concertsRegister[_concertId].artistId].totalTicketSold+=concertsRegister[_concertId].totalSoldTicket;


  }



  function offerTicketForSale(uint _ticketId, uint _salePrice) public {


  	require (msg.sender==ticketsRegister[_ticketId].owner);
  	require(ticketsRegister[_ticketId].amountPaid>=_salePrice);
  	ticketsRegister[_ticketId].isAvailableForSale=true;
  	ticketsRegister[_ticketId].salePrice=_salePrice;

  }

  function buySecondHandTicket(uint _ticketId) payable public {
  	require(ticketsRegister[_ticketId].isAvailableForSale==true);
  	require(msg.value==ticketsRegister[_ticketId].salePrice);

  	require(ticketsRegister[_ticketId].amountPaid>=msg.value);
  	require(ticketsRegister[_ticketId].isAvailable==true);

  	ticketsRegister[_ticketId].owner.transfer(msg.value);
  	ticketsRegister[_ticketId].owner=msg.sender;
  }





}

