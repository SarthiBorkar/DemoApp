// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EmployeePayment {
    address public owner;
    mapping(address => uint256) public employeeHours;
    mapping(address => uint256) public employeeRates;

   

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function setEmployeeRate(address employee, uint256 rate) public onlyOwner {
        employeeRates[employee] = rate;
        emit RateSet(employee, rate);
    }

    function logHours(address employee, uint256 hours) public onlyOwner {
        employeeHours[employee] += hours;
        emit HoursLogged(employee, hours);
    }

    function payEmployee(address payable employee) public onlyOwner {
        uint256 payment = employeeHours[employee] * employeeRates[employee];
        require(address(this).balance >= payment, "Insufficient contract balance");
        
        employeeHours[employee] = 0;  // Reset hours after payment
        (bool success, ) = employee.call{value: payment}("");  // Use low-level call to handle Ether transfer
        require(success, "Payment failed");

        emit PaymentMade(employee, payment);
    }

    function deposit() external payable onlyOwner {}

    receive() external payable {}
}
