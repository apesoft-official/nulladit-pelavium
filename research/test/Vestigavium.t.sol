// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;
import "../Vestigium.sol";

interface Vm {
    function chainId(uint256) external;
    function prank(address) external;
    function expectRevert(bytes4) external;
}
contract MockCovenant is IVestigiumCovenant {
    bytes32 public override foundationRoot = keccak256("foundation");
    bool public approved;
    bool public revoked;
    bytes32 public manifest;
    function configure(bool a, bool r, bytes32 m) external {
        approved = a; revoked = r; manifest = m;
    }
    function isReleaseApproved(uint64) external view override returns(bool) { return approved; }
    function releases(uint64) external view override returns(bytes32,bytes32,bytes32,uint64,bool) {
        return (bytes32(0),bytes32(0),manifest,1,revoked);
    }
}
contract VestigiumTest {
    Vm constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    MockCovenant c;
    Vestigium v;
    bytes32 constant ROOT = keccak256("synthetic batch");
    function setUp() public {
        vm.chainId(324);
        c = new MockCovenant();
        v = new Vestigium(address(c),c.foundationRoot(),keccak256("manifest"),1,address(this));
    }
    function approve() internal { c.configure(true,false,v.configurationCommitment()); }
    function testInactiveInitially() public { require(!v.active()); }
    function testApprovedBatch() public {
        approve(); require(v.active()); v.commitBatch(1,ROOT);
        require(v.batchRoots(1)==ROOT && v.lastEpoch()==1);
    }
    function testUnapproved() public {
        vm.expectRevert(Vestigium.NotApproved.selector); v.commitBatch(1,ROOT);
    }
    function testWrongCommitment() public {
        c.configure(true,false,ROOT); require(!v.active());
    }
    function testRevoked() public {
        approve(); c.configure(true,true,v.configurationCommitment()); require(!v.active());
    }
    function testUnauthorized() public {
        approve(); vm.expectRevert(Vestigium.Unauthorized.selector);
        vm.prank(address(123)); v.commitBatch(1,ROOT);
    }
    function testReplay() public {
        approve(); v.commitBatch(1,ROOT);
        vm.expectRevert(Vestigium.InvalidBatch.selector); v.commitBatch(1,ROOT);
    }
    function testSkippedEpoch() public {
        approve(); vm.expectRevert(Vestigium.InvalidBatch.selector); v.commitBatch(2,ROOT);
    }
    function testZeroRoot() public {
        approve(); vm.expectRevert(Vestigium.InvalidBatch.selector); v.commitBatch(1,bytes32(0));
    }
    function testWrongChain() public { approve(); vm.chainId(1); require(!v.active()); }
    function testDifferentInstance() public {
        approve();
        Vestigium other = new Vestigium(address(c),c.foundationRoot(),keccak256("manifest"),1,address(this));
        require(!other.active());
    }
}
