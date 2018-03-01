pragma solidity 0.4.19;

import "./AuctionInterface.sol";

/** @title BadAuction */
contract BadAuction is AuctionInterface {

    struct Refund {
        uint funds;
        bool initialized;
    }

    mapping(address => Refund) refunds;
/* Bid function, vulnerable to reentrency attack.
    * Must return true on successful send and/or bid,
    * bidder reassignment
    * Must return false on failure and send people
    * their funds back
    */

    function bid() external payable returns (bool) {
        // YOUR CODE HERE

        // reentrency attack, this function can be called again before
        // the first invocation of the function was finished
        address lastHighestBidder = 0;
        if (msg.value > highestBid) {
            refunds[highestBidder] = Refund(highestBid, true); 
            lastHighestBidder = highestBidder; 
            
            if (refund(lastHighestBidder)) {
                highestBid = msg.value;
                highestBidder = msg.sender; 
            }
            return true;
        } else {
            refunds[msg.sender] = Refund(msg.value, true); 
            refund(msg.sender);
            return false;
        }
        
    }
    
    function refund(address addrs) private returns (bool) {
        if (refunds[addrs].initialized) {
            uint funds = refunds[addrs].funds;
            refunds[addrs].funds = 0;
            refunds[addrs].initialized = false;
            if (!addrs.send(funds)) {
                if (msg.sender.send(msg.value)) {
                    return false;
                }
                return false;
            }
            return true;
        }
        return false;
    }
    
    /* 	Reduce bid function. Vulnerable to attack.
        Allows current highest bidder to reduce 
        their bid by 1. Do NOT make changes here.
        Instead notice the vulnerabilities, and
        implement the function properly in GoodAuction.sol  */

    function reduceBid() external {
        if (highestBid >= 0) {
            highestBid = highestBid - 1;
            require(highestBidder.send(1));
        } 
    }

    // underflow and check only the highestbidder is reducing
    modifier canReduce() {
        require(highestBidder == msg.sender);
        _;
    }

    /* in any situation a bidder with a lower or the same bid
    than the current higgest bidder shiuld have not effect on the contract */
    modifier bidIsAccepted() {
        
        _;
    }


    /* 	Remember this fallback function
        gets invoked if somebody calls a
        function that does not exist in this
        contract. But we're good people so we don't
        want to profit on people's mistakes.
        How do we send people their money back?  */

    function () payable {
        // YOUR CODE HERE
        msg.sender.transfer(msg.value);
    }

}