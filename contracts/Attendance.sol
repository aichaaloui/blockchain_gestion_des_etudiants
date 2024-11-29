// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

contract Attendance {
    // Structure pour enregistrer l'étudiant
    struct Student {
        string name;
        bool isPresent;
        uint256 timestamp;
    }

    mapping(address => Student) public students;
    address public owner;

    event AttendanceMarked(address studentAddress, bool isPresent);

    modifier onlyOwner() {
        require(msg.sender == owner, "Vous n'êtes pas autorisé !");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    // Fonction pour marquer la présence d'un étudiant
    function markAttendance(address studentAddress, string memory name, bool isPresent) public onlyOwner {
        students[studentAddress] = Student(name, isPresent, block.timestamp);
        emit AttendanceMarked(studentAddress, isPresent);
    }

    // Fonction pour obtenir le statut de présence d'un étudiant
    function getAttendance(address studentAddress) public view returns (string memory name, bool isPresent, uint256 timestamp) {
        Student memory student = students[studentAddress];
        return (student.name, student.isPresent, student.timestamp);
    }
}
