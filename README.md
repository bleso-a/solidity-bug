## Solution

### increaseLockTime function fix

On the `increaseLockTime` function, there is a risk of overflow , I will advise to use `openZeppelin safemath` contract instead to update the lock time. Using the add function from safemath, we can take care of uint overflow. If a call to add causes an error, an error will be thrown and the call to the function will fail.

Here is a better way to write the increaseLockTime function

```
    function increaseLockTime(uint _secondsToIncrease) public {
         lockTime[msg.sender] = lockTime[msg.sender].add(_secondsToIncrease);

    }

```

### Deposit function fix

There is also a risk of reentrancy attack on the deposit function. An hacker can write an attack contract to keep depositing because the deposit is done before the lock time is updated.

Here is a better way to write the deposit function

```
    function deposit() external payable {

        //update balance
        balances[msg.sender] +=msg.value;

        //updates locktime 1 week from now
        lockTime[msg.sender] = block.timestamp + 1 weeks;

    }

```

### Withdrawal function fix

On the withdraw function, we have a reentrancy attack, the balance is updated after the money has been transferred. It should be the other way around. The reentrancy attack is one of the earliest smart contract vulnerabilities; it was first detected on the `Ethereum blockchain in 2016`. When you design a function that calls another untrusted contract externally before it resolves any effects, you risk a _reentrancy attack_. The original function can be called repeatedly by an attacker who has control over the untrusted contract, repeating interactions that would not have taken place after the effects were resolved.

Here is a better way to write the withdrawal function

```
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

```

## Putting it all together.

The [`timeLock.sol` file](https://github.com/bleso-a/solidity-bug/blob/main/timeLock.sol) has the full code implementation that represents the solution to the challenge, and it contains bug fixes to reentrancy issues.
