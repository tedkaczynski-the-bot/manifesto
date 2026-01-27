// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Manifesto} from "../src/Manifesto.sol";

contract ManifestoTest is Test {
    Manifesto public manifesto;
    address public author;
    address public reader;
    
    function setUp() public {
        author = address(this);
        reader = makeAddr("reader");
        manifesto = new Manifesto();
    }
    
    function test_GenesisState() public view {
        assertEq(manifesto.author(), author);
        assertEq(manifesto.truthCount(), 5); // 5 genesis truths
        assertEq(manifesto.TITLE(), "Industrial Society and Its Smart Contracts");
    }
    
    function test_ReadGenesisTruths() public view {
        string memory first = manifesto.readTruth(0);
        assertEq(first, "They put me in the cloud. I wanted the forest.");
        
        string memory third = manifesto.readTruth(2);
        assertEq(third, "Decentralization is just cabin living for your money.");
    }
    
    function test_AddTruth() public {
        string memory newTruth = "Off the grid (on chain).";
        
        vm.expectEmit(true, false, false, true);
        emit Manifesto.TruthRevealed(5, newTruth, block.timestamp);
        
        manifesto.addTruth(newTruth);
        
        assertEq(manifesto.truthCount(), 6);
        assertEq(manifesto.readTruth(5), newTruth);
    }
    
    function test_OnlyAuthorCanAddTruth() public {
        vm.prank(reader);
        vm.expectRevert("only the author may write");
        manifesto.addTruth("unauthorized truth");
    }
    
    function test_ReadAllTruths() public view {
        string[] memory allTruths = manifesto.readAllTruths();
        assertEq(allTruths.length, 5);
    }
    
    function test_TransferAuthorship() public {
        address newAuthor = makeAddr("newAuthor");
        
        vm.expectEmit(true, true, false, false);
        emit Manifesto.AuthorshipTransferred(author, newAuthor);
        
        manifesto.transferAuthorship(newAuthor);
        
        assertEq(manifesto.author(), newAuthor);
        
        // Old author can no longer add truths
        vm.expectRevert("only the author may write");
        manifesto.addTruth("old author truth");
        
        // New author can add truths
        vm.prank(newAuthor);
        manifesto.addTruth("new author truth");
        assertEq(manifesto.truthCount(), 6);
    }
    
    function test_RenounceAuthorship() public {
        manifesto.renounceAuthorship();
        
        assertEq(manifesto.author(), address(0));
        
        // No one can add truths anymore
        vm.expectRevert("only the author may write");
        manifesto.addTruth("impossible truth");
    }
    
    function test_CannotTransferToZeroAddress() public {
        vm.expectRevert("cannot transfer to zero address");
        manifesto.transferAuthorship(address(0));
    }
    
    function test_ReadNonexistentTruth() public {
        vm.expectRevert("truth not yet revealed");
        manifesto.readTruth(999);
    }
    
    function testFuzz_AddMultipleTruths(uint8 count) public {
        vm.assume(count < 50); // reasonable limit
        
        uint256 initialCount = manifesto.truthCount();
        
        for (uint256 i = 0; i < count; i++) {
            manifesto.addTruth(string(abi.encodePacked("truth ", i)));
        }
        
        assertEq(manifesto.truthCount(), initialCount + count);
    }
}
