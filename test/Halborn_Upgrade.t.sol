// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Merkle} from "./murky/Merkle.sol";

import {HalbornNFT} from "../src/HalbornNFT.sol";
import {HalbornToken} from "../src/HalbornToken.sol";
import {HalbornLoans} from "../src/HalbornLoans.sol";

import "@openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";



contract HalbornUpgradeTest is Test {
    address public immutable ALICE = makeAddr("ALICE");
    address public immutable BOB = makeAddr("BOB");
    address owner = address(1);

    bytes32[] public ALICE_PROOF_1;
    bytes32[] public ALICE_PROOF_2;
    bytes32[] public BOB_PROOF_1;
    bytes32[] public BOB_PROOF_2;


    HalbornNFT public nftImpl;
    HalbornNFT public nftImplV2;
    HalbornNFT public nft;
    ERC1967Proxy public nftProxy;


    HalbornToken public tokenImpl;
    HalbornToken public tokenImplV2;
    HalbornToken public token;
    ERC1967Proxy public tokenProxy;


    HalbornLoans public loansImpl;
    HalbornLoans public loansImplV2;
    HalbornLoans public loans;
    ERC1967Proxy public loansProxy;




    function setUp() public {

        vm.startPrank(owner);
        // Initialize
        Merkle m = new Merkle();
        // Test Data
        bytes32[] memory data = new bytes32[](4);
        data[0] = keccak256(abi.encodePacked(ALICE, uint256(15)));
        data[1] = keccak256(abi.encodePacked(ALICE, uint256(19)));
        data[2] = keccak256(abi.encodePacked(BOB, uint256(21)));
        data[3] = keccak256(abi.encodePacked(BOB, uint256(24)));

        // Get Merkle Root
        bytes32 root = m.getRoot(data);

        // Get Proofs
        ALICE_PROOF_1 = m.getProof(data, 0);
        ALICE_PROOF_2 = m.getProof(data, 1);
        BOB_PROOF_1 = m.getProof(data, 2);
        BOB_PROOF_2 = m.getProof(data, 3);


        nftImpl = new HalbornNFT();
        nftProxy = new ERC1967Proxy(address(nftImpl), "");
        nft = HalbornNFT(address(nftProxy));


        tokenImpl = new HalbornToken();
        tokenProxy = new ERC1967Proxy(address(tokenImpl), "");
        token = HalbornToken(address(tokenProxy));



        loansImpl = new HalbornLoans(2 ether);
        loansProxy = new ERC1967Proxy(address(loansImpl), "");
        loans = HalbornLoans(address(loansProxy));


        nft.initialize(root, 1 ether);
        token.initialize();
        loans.initialize(address(token), address(nft));


        vm.stopPrank();
    }




    // @Audit [C-01]
    function test_EveryoneCanUpgradeNFTContractToNewVersion()public{
        vm.startPrank(ALICE);
        nftImplV2 = new HalbornNFT();
        nft.upgradeTo(address(nftImplV2));
        vm.stopPrank();
    }




    // @Audit [C-02]
    function test_EveryoneCanUpgradeTokenContractToNewVersion()public{
        vm.startPrank(ALICE);
        tokenImplV2 = new HalbornToken();
        token.upgradeTo(address(tokenImplV2));
        vm.stopPrank();
    }





    // @Audit [C-03]
    function test_EveryoneCanUpgradeLoansContractToNewVersion()public{
        vm.startPrank(ALICE);
        loansImplV2 = new HalbornLoans(1000000 ether);
        loans.upgradeTo(address(loansImplV2));
        vm.stopPrank();
    }

}