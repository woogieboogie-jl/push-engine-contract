// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {DataStreamsFeed} from "../src/feed/DataStreamsFeed.sol"; // Import the main contract

/**
 * @title Deployment Script for the original DataStreamsFeed
 * @dev [LEGACY] Deploys a non-upgradeable instance of `DataStreamsFeed` **and** immediately
 *      grants the caller the REPORT_VERIFIER role.  You only need this role when you plan to
 *      push *pre-verified* reports on-chain via `updateReport(uint16,bytes)` (off-chain
 *      verification path).
 *
 *      If you use the recommended on-chain verification flow — calling
 *      `verifyAndUpdateReport(bytes,bytes)` from the transmitter — **do NOT** run this script.
 *      Just deploy with `DeployDataStreamsFeed.s.sol` and fund the deployed contract with LINK.
 *
 *      The script is kept for backwards-compatibility and testing purposes.
 */
contract DeployDataStreamsFeedWithRoleAssign is Script {
    function run() external returns (address deployedAddress) {
        // =================================================================
        // │                  CONFIGURATION PARAMETERS                     │
        // =================================================================

        // The official Chainlink Verifier Proxy address for your target chain.
        // The contract at this address MUST have the s_feeManager() function.
        address verifierProxyAddress = 0x60fAa7faC949aF392DFc858F5d97E3EEfa07E9EB; // <-- TODO: Replace with official address

        // The unique ID for the Data Stream you want to track (e.g., ETH/USD).
        bytes32 feedId = 0x000359843a543ee2fe414dc14c7e7920ef10f4372990b79d6361cdc0dd1ba782; // <-- TODO: Replace with the desired feed ID

        // The number of decimals for the price data.
        uint8 decimals = 18;

        // The maximum value for report expiration duration
        uint32 maxExpiration = 30 days;

        // A human-readable description for the feed.
        string memory description = "My Custom ETH / USD Feed";
        
        // =================================================================
        // │                        DEPLOYMENT LOGIC                       │
        // =================================================================
        
        // Start the broadcast. The next call will be a sent transaction.
        vm.startBroadcast();
        address deployer = msg.sender;

        // Deploy the DataStreamsFeed contract in a single transaction.
        // We do NOT pass the feeManagerAddress, as the contract finds it itself.
        console.log("Deploying DataStreamsFeed (Community Driven)...");
        DataStreamsFeed feed = new DataStreamsFeed(
            verifierProxyAddress,
            feedId,
            decimals,
            maxExpiration,
            description
        );
        
        deployedAddress = address(feed);
        console.log("DataStreamsFeed deployed at:", deployedAddress);

        // Grant the REPORT_VERIFIER role to the externally-owned account that
        // is broadcasting the transaction (i.e. the deployer's wallet), not
        // the transient script contract address.
        feed.grantRole(feed.REPORT_VERIFIER(), deployer);
        console.log("REPORT VERIFIER Role granted successfully to deployer");

        // Stop the broadcast.
        vm.stopBroadcast();

        return deployedAddress;
    }
}
