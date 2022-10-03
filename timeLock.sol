pragma solidity >=0.7.0 <0.9.0;

// use safe math to prevent underflow and overflow
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
 

contract TimeLock {
    

    // SafeMath will add extra functions to the uint data type
    using SafeMath for uint;
    

    // amount of ether you deposited is saved in balances
    mapping(address => uint) public balances;
  
    mapping(address => uint) public lockTime;

    function deposit() external payable {

        //update balance
        balances[msg.sender] +=msg.value;

        //updates locktime 1 week from now
        lockTime[msg.sender] = block.timestamp + 1 weeks;

    }

     

    function increaseLockTime(uint _secondsToIncrease) public {
         lockTime[msg.sender] = lockTime[msg.sender].add(_secondsToIncrease);

    }

      

    function withdraw() public {

        // check that the sender has ether deposited in this contract in the mapping and the balance is >0
        require(balances[msg.sender] > 0, "insufficient funds");

        // check that the now time is > the time saved in the lock time mapping
        require(block.timestamp > lockTime[msg.sender], "lock time has not expired");
      

        // update the balance
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

       
        // send the ether back to the sender
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send ether");

    }
}
