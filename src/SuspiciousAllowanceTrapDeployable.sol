// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ITrap.sol";

interface IERC20 {
    function allowance(address owner, address spender) external view returns (uint256);
}

contract SuspiciousAllowanceTrapDeployable is ITrap {
    address public constant TOKEN = 0xA2d07904D9729D8E1bE1748B2a869Afb3Baa1410;
    uint256 public constant THRESHOLD = 1000 ether;

    address[] public owners;
    address[] public spenders;

    constructor() {
        owners.push(0x742D35Cc9cC5027b4C3F8752928f1f0a8c1Fd8C5);
        spenders.push(0x1234567890123456789012345678901234567890);
    }

    function collect() external view override returns (bytes memory) {
        uint256 len = owners.length;
        
        if (len == 0) {
            address[] memory emptyAddresses = new address[](0);
            uint256[] memory emptyAmounts = new uint256[](0);
            return abi.encode(emptyAddresses, emptyAddresses, emptyAmounts);
        }

        address[] memory _owners = new address[](len);
        address[] memory _spenders = new address[](len);
        uint256[] memory _allowances = new uint256[](len);

        for (uint256 i = 0; i < len; i++) {
            _owners[i] = owners[i];
            _spenders[i] = spenders[i];
            
            try IERC20(TOKEN).allowance(owners[i], spenders[i]) returns (uint256 allowance) {
                _allowances[i] = allowance;
            } catch {
                _allowances[i] = 0;
            }
        }

        return abi.encode(_owners, _spenders, _allowances);
    }

    function isWhitelisted(address spender) internal pure returns (bool) {
        // Hardcoded whitelist - add addresses as needed
        return spender == 0xb7F273445A7f40E381DE95e0061714d06217358F;
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, "");

        (address[] memory ownersC, address[] memory spendersC, uint256[] memory allowancesC) =
            abi.decode(data[0], (address[], address[], uint256[]));
        (address[] memory ownersP, address[] memory spendersP, uint256[] memory allowancesP) =
            abi.decode(data[1], (address[], address[], uint256[]));

        if (ownersC.length != ownersP.length) return (false, "");
        for (uint256 i = 0; i < ownersC.length; i++) {
            if (ownersC[i] != ownersP[i] || spendersC[i] != spendersP[i]) {
                continue;
            }
            if (allowancesC[i] > allowancesP[i]) {
                uint256 delta = allowancesC[i] - allowancesP[i];
                
                if (delta >= THRESHOLD && !isWhitelisted(spendersC[i])) {
                    return (true, abi.encode(ownersC[i], spendersC[i], allowancesP[i], allowancesC[i]));
                }
            }
        }
        return (false, "");
    }
}
