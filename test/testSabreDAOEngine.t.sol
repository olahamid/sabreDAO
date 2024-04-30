// import {SabreDAOEngine} from "../src/SabreDAOEngine.sol";
// import {Test} from "../lib/forge-std/src/Test.sol";
// import {deploySabreDAOEngine} from "../script/deploySabreDAOEngine.s.sol";
// import {helperConfig} from "../script/helperConfig.s.sol";
// import {SabreDAO} from "../src/SabreDAO.sol";
// import {SabreDAOStaking} from "../src/SabreDAOStaking.sol";
// import {SabreDAOGovernorPro} from "../src/SabreDAOGovernorPro.sol";
// import {TimeLock} from "../src/TimeLock.sol";
// import {S_vault} from "../src/S_vault.sol";
// import {ERC20ForceApproveMock} from "../lib/openzeppelin-contracts/contracts/mocks/token/ERC20ForceApproveMock.sol";
// import {ERC20Mock} from "../lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

// contract testSabreDAOEngine is Test {
//     deploySabreDAOEngine deployer;
//     SabreDAOGovernorPro SBRGov;
//     SabreDAOEngine SBREngine;
//     SabreDAOStaking SBRStaking;
//     helperConfig HelperConfig;
//     TimeLock timeLock;
//     S_vault vault;

//     SabreDAO Sbr;
//     uint256 _proposalFee;
//     uint256 _votingFee;
//     uint256 _timePoint;
//     uint256 _proposalID;

//     address public USER = makeAddr("user");

//     function setUp() public {
//        deployer = new deploySabreDAOEngine();
//        (Sbr, HelperConfig, SBREngine, vault, timeLock, SBRStaking) = deployer.run();
//         (uint256 _proposalFee,
//         uint256 _votingFee,
//         uint256 _timePoint,
//         uint256 _proposalID,) = HelperConfig.activeNetworkConfig();
//                // Mint the required amount of WETH to the user's account
//     }
//     function testBuyToken() public {

//     }

// }
