pragma solidity 0.4.19;

import "./AuctionInterface.sol";

/** @title GoodAuction */
contract GoodAuction is AuctionInterface {

    /* New data structure, keeps track of refunds owed */
    struct Refund {
        uint funds;
        bool initialized;
    }

    mapping(address => Refund) refunds;

    /* 	Bid function, now shifted to pull paradigm
    Must return true on successful send and/or bid, bidder
    reassignment. Must return false on failure and 
    allow people to retrieve their funds  */


    function bid() payable external returns(bool) {

        // higher bid should displace last highest bid 
        // if previous higher bidder were not poisoned

        // Be able to displace the previous highest bidder 
        // if bidding at a good auction

        // Not be able to displace the previous highest bidder 
        // if bidding on a bad auction and the previous highest bidder was poisoned
        if (msg.value > highestBid) {
            if (highestBidder != 0) {
                refunds[highestBidder].funds = highestBid; 
                refunds[highestBidder].initialized = true; 
            }

            highestBid = msg.value;
            highestBidder = msg.sender; 
            return true;
        } else {
            return false;
        }
    }

    // pull over push transactions
    function returnFunds() private returns (bool) {
        if (!msg.sender.send(msg.value)) {
            return false;
        }
        return true;
    }

    /*  Implement withdraw function to complete new 
    pull paradigm. Returns true on successful 
    return of owed funds and false on failure
    or no funds owed.  */
    function withdrawRefund() external returns(bool) {
        // YOUR CODE HERE
        if (!(refunds[msg.sender].initialized && returnFund())) {
            return false;
        }
        return true;
    }

    function returnFund() private returns (bool) {
        if (!msg.sender.send(refunds[msg.sender].funds)) {
            return false;
        }
        return true;
    }

    /*  Allow users to check the amount they are owed
    before calling withdrawRefund(). Function returns
    amount owed.  */
    function getMyBalance() external constant  returns(uint) {
        if (refunds[msg.sender].initialized == true) {
            return refunds[msg.sender].funds;
        } else {
            return 0;
        }
    }

    /* in any situation a bidder with a lower or the same bid
    than the current higgest bidder shiuld have not effect on the contract */
    modifier bidIsAccepted() {
        require(msg.value > highestBid);
        _;
    }

    /* 	Consider implementing this modifier
    and applying it to the reduceBid function 
    you fill in below. */

    // underflow and check only the highestbidder is reducing
    modifier canReduce() {
        require(msg.sender == highestBidder);
        _;
    }


    /*  Rewrite reduceBid from BadAuction to fix
    the security vulnerabilities. Should allow the
    current highest bidder only to reduce their bid amount */

    // should be protected against underflow

    function reduceBid() external {
        // bad auction doesn't check for the send to decrease bid
        if (highestBidder == msg.sender && highestBid > 0 && highestBid - 1 >= 0) {
            highestBidder.transfer(1);
            highestBid -= 1;
        }
    }


    /* 	Remember this fallback function
    gets invoked if somebody calls a
    function that does not exist in this
    contract. But we're good people so we don't
    want to profit on people's mistakes.
    How do we send people their money back?  */

    function () payable {
        msg.sender.transfer(msg.value);
    }

}
