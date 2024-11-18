// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/// @title SparkoutToken
/// @notice This contract implements a token with additional features like blacklisting, fees, and transfer limits.
contract SparkoutToken is ERC20, ERC20Permit, Ownable, Pausable{
    mapping(address => bool) public blacklisted;
    uint256 public maxTransferLimit;
    uint256 public feePercentage;

//Event for successful transfer after fee deduction
event FeeDeducted(address indexed from, address indexed to, uint256 feeAmount, uint256 amountAfterFee);
event TransferSuccessful(address indexed from, address indexed to, uint256 amount, uint256 feeAmount);

   constructor() ERC20("Spark", "SOT") ERC20Permit("Spark")Ownable(msg.sender){
        _mint(msg.sender, 1000000 * 10 ** decimals());
        feePercentage = 2; 
        maxTransferLimit = 1000000 * 10 ** decimals();
    } 
/// @notice Adds an address to the blacklist.
/// @param account The address to blacklist.
    function addToBlacklist(address account) public onlyOwner {
        blacklisted[account] = true;
    }
/// @notice Removes an address from the blacklist.
/// @param account The address to remove from the blacklist.
    function removeFromBlacklist(address account) public onlyOwner {
        blacklisted[account] = false;
    }

    function setMaxTransferLimit(uint256 limit) public onlyOwner {
        maxTransferLimit = limit;
    }

    function setFeePercentage(uint256 newFee) public onlyOwner {
        feePercentage = newFee;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function withdrawFees() public onlyOwner {
        uint256 contractBalance = balanceOf(address(this)); 
        require(contractBalance > 0, "No fees available to withdraw");
        _transfer(address(this), msg.sender, contractBalance);
    }

    modifier notBlacklisted(address account) {
        require(!blacklisted[account], "Account is blacklisted");
        _;
    }

    modifier belowMaxTransferLimit(uint256 amount) {
        require(amount <= maxTransferLimit, "Amount exceeds the maximum transfer limit");
        _;
    }

    function transfer(address to, uint256 amount) public override notBlacklisted(msg.sender) notBlacklisted(to) belowMaxTransferLimit(amount) whenNotPaused returns (bool) {
       
        require(balanceOf(msg.sender) >= amount, "Insufficient balance to transfer");

        uint256 feeAmount = (amount * feePercentage) / 100;
        uint256 amountAfterFee = amount - feeAmount;
        
        //emit event for fee deduction
        emit FeeDeducted(msg.sender, to, feeAmount, amountAfterFee);

        //Transfer the fee to the contract itself
        _transfer(msg.sender, address(this), feeAmount);

        //proceed with normal transfer after deducting the fee
        _transfer(msg.sender, to, amountAfterFee);

        
        //Emit event for successful transfer after fee
        emit TransferSuccessful(msg.sender, to, amountAfterFee, feeAmount);
        
        return true;

    }
    function transferFrom(address from, address to, uint256 amount) public override notBlacklisted(from) notBlacklisted(to) belowMaxTransferLimit(amount) whenNotPaused returns (bool) {
     require(balanceOf(from) >= amount, "Insufficient balance");
     require(allowance(from, msg.sender) >= amount, "Allowance too low");

     uint256 feeAmount = (amount * feePercentage) / 100;
     uint256 amountAfterFee = amount - feeAmount;

     // Emit event for fee deduction
     emit FeeDeducted(from, to, feeAmount, amountAfterFee);

     // Transfer the fee to the contract itself
     _transfer(from, address(this), feeAmount);

     // Proceed with normal transfer after fee deduction
     _transfer(from, to, amountAfterFee);

     // Reduce the allowance by the transferred amount
     _approve(from, msg.sender, allowance(from, msg.sender) - amount);

     // Emit event for successful transfer after fee
     emit TransferSuccessful(from, to, amountAfterFee, feeAmount);

     return true;
 }

    


}
        
      