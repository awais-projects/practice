// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Payroll{
    address public employer;

    struct Employee{
        uint salary;
        uint lastPayDay;
    }

    mapping (address => Employee) public employees;

    modifier OnlyEmployer() {
        require(msg.sender == employer,"Only the employer can call this function.");
        _;
    }

    constructor () {
        employer = msg.sender;
    }

    function setEmployee(address _employeeAddress, uint _salary) public OnlyEmployer {
        employees[_employeeAddress] = Employee({
            salary: _salary,
            lastPayDay: block.timestamp
        });
    }

    function issueSalary(address _employeeAddress) public OnlyEmployer {
        Employee storage employee = employees[_employeeAddress];

        require(employee.salary > 0,"Employee not found.");
        require(block.timestamp >= employee.lastPayDay + 30 days,"Salary already issued for this month");

        employee.lastPayDay = block.timestamp;
        payable(_employeeAddress).transfer(employee.salary);
    }

    function fundContract() public payable OnlyEmployer {}

    function getContractBalance() public view returns (uint) {
        return address(this).balance; 
    }
    }