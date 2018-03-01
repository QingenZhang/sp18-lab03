pragma solidity 0.4.19;

import "./AuctionInterface.sol";

/** @title GoodAuction */
contract GoodAuction is AuctionInterface {

	/* New data structure, keeps track of refunds owed */
	mapping(address => uint) refunds;

	/* 	Bid function, now shifted to pull paradigm
		Must return true on successful send and/or bid, bidder
		reassignment. Must return false on failure and 
		allow people to retrieve their funds  */
	function bid() payable external returns(bool) {
		// YOUR CODE HERE
		uint high = super.getHighestBid();
		if (msg.value <= high) {
			refunds[msg.sender] = msg.value;
			return false;
		} else {
			refunds[super.getHighestBidder()] = high;
			highestBid = msg.value;
			highestBidder = msg.sender;
			return true;
		}
	}

	/*  Implement withdraw function to complete new 
	    pull paradigm. Returns true on successful 
	    return of owed funds and false on failure
	    or no funds owed.  */
	function withdrawRefund() external returns(bool) {
		// YOUR CODE HERE
        uint amount = refunds[msg.sender];
        if (amount > 0) {
            refunds[msg.sender] = 0;
            msg.sender.transfer(amount);
			return true;
        }
		return false;
	}

	/*  Allow users to check the amount they are owed
		before calling withdrawRefund(). Function returns
		amount owed.  */
	function getMyBalance() constant external returns(uint) {
		return refunds[msg.sender];
	}


	/* 	Consider implementing this modifier
		and applying it to the reduceBid function 
		you fill in below. */
	modifier canReduce() {
		_;
	}


	/*  Rewrite reduceBid from BadAuction to fix
		the security vulnerabilities. Should allow the
		current highest bidder only to reduce their bid amount */
	function reduceBid() external {
	    if (msg.sender == highestBidder && highestBid >= 1) {
	        highestBid = highestBid - 1;
	        require(highestBidder.send(1));
	    }
	}


	/* 	Remember this fallback function
		gets invoked if somebody calls a
		function that does not exist in this
		contract. But we're good people so we don't
		want to profit on people's mistakes.
		How do we send people their money back?  */

	function () payable {
		// YOUR CODE HERE
		throw;
	}

}
