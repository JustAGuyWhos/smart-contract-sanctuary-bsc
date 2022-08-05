/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

//SPDX-License_Identifier:MIT

pragma solidity ^0.6.0;

contract SimpleStorage{

   uint256 public favoriteNumber;

   struct People{
       uint256 favoriteNumber;
       string name;
   } 
   
   People[] public people;

   mapping(string => uint256)public nameToFavoriteNumber;
   


   function store(uint256 _favoriteNumber)public{
       favoriteNumber = _favoriteNumber;
   }

   function retrieve(uint256 favoriteNumber)public view returns(uint256){
       return favoriteNumber;
   }

   function addPerson(string memory _name, uint256 _favoriteNumber) public{
       people.push(People(_favoriteNumber, _name));
       nameToFavoriteNumber[_name] = _favoriteNumber;
   }

}