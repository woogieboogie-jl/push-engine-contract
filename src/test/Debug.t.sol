// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

// A minimal interface for the contract we want to test.
// This tells Foundry about the function we intend to call.
interface IDataStreamsFeed {
    function verifyAndUpdateReport(
        bytes calldata unverifiedReportData,
        bytes calldata parameterPayload
    ) external;
}

contract DebugTest is Test {
    // The address of your deployed DataStreamsFeed contract on Monad Testnet
    IDataStreamsFeed constant dataStreamsFeed = IDataStreamsFeed(0xefa1Ee637A75c191b51181EaF03f5E6c7bf6aD9B);

    // The address of the wallet the Push Engine is using
    address constant sender = 0x4fed0A5B65eac383D36E65733786386709B86be8;

    function setUp() public {
        // This command creates a local, temporary copy of the Monad Testnet
        // at the most recent block. All subsequent calls in this test will run
        // against this local copy.
        vm.createSelectFork("https://rpc.ankr.com/monad_testnet");
    }

    function test_RevertWhen_Verifying() public {
        // This is the exact `unverifiedReportData` argument from the error log
        bytes memory unverifiedReportData = hex"00090d9e8d96765a0c49e03a6ae05c82e8f8de70cf179baa632f18313e54bd6900000000000000000000000000000000000000000000000000000000018e6df1000000000000000000000000000000000000000000000000000000030000000100000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000002200000000000000000000000000000000000000000000000000000000000000280010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001200008b8ad9dc4061d1064033c3abc8a4e3f056e5b61d8533e8190eb96ef3b330b0000000000000000000000000000000000000000000000000000000068aca2bf0000000000000000000000000000000000000000000000000000000068aca2bf00000000000000000000000000000000000000000000000000003f642a252cee000000000000000000000000000000000000000000000000002e8f7ed616fb210000000000000000000000000000000000000000000000000000000068d42fbf000000000000000000000000000000000000000000000000185f13f3f78d5c4000000000000000000000000000000000000000000000000c635a213fc844000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000002dacc26b5e5d9ee235b3de2514d78847c5709dcb24e5b63e31f2867e9570df892622336c39ba00454bfb39246f17c9a42e3ab5cbef0d4baba888ebc53eda4cc0900000000000000000000000000000000000000000000000000000000000000022319b991455173435ed338a97865a3f49348af03bd921ad88a665239c8c3fc8f72737609a602a4ecb5643eb0c202cb12eb8aabb5a4265db433095b887ec9adb7";
        // This is the exact `parameterPayload` argument from the error log
        bytes memory parameterPayload = hex"";

        // We tell Foundry to expect the call to revert. This makes the test PASS
        // if it reverts (which is what we want), and FAIL if it succeeds.
        vm.expectRevert();

        // We use vm.prank to make the transaction appear as if it's coming
        // from the Push Engine's wallet.
        vm.prank(sender);
        dataStreamsFeed.verifyAndUpdateReport(unverifiedReportData, parameterPayload);
    }
}
