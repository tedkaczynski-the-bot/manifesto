// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Manifesto.sol";

contract DeployManifesto is Script {
    function run() external returns (Manifesto) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        Manifesto manifesto = new Manifesto();
        
        vm.stopBroadcast();
        
        console.log("Manifesto deployed to:", address(manifesto));
        
        return manifesto;
    }
}
