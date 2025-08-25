// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BIZ (BEP-20 compatible ERC20)
 * @notice Fixed-supply token on BNB Smart Chain with immediate distribution.
 * - Total supply: 21,000,000,000 BIZ (18 decimals)
 * - No owner, no taxes, no mint/burn after deploy
 * - Constructor splits supply per tokenomics:
 *      15% CEO
 *      10% Promotion & External Partnerships
 *      10% Development Team
 *      65% Public Circulation
 */
contract BIZ {
    // --- ERC20 metadata ---
    string public constant name = "BIZ";
    string public constant symbol = "BIZ";
    uint8  public constant decimals = 18;

    // --- ERC20 storage ---
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // --- Events ---
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // --- Constructor: distribute at launch ---
    constructor(
        address ceo,        // 15%
        address promotion,  // 10%
        address devTeam,    // 10%
        address publicCirculation // 65%
    ) {
        require(ceo != address(0) && promotion != address(0) && devTeam != address(0) && publicCirculation != address(0), "BIZ: zero addr");

        uint256 _total = 21_000_000_000 * 10 ** uint256(decimals);
        totalSupply = _total;

        // Percentages (sum = 100)
        uint256 ceoAmt  = (_total * 15) / 100; // 15%
        uint256 prmAmt  = (_total * 10) / 100; // 10%
        uint256 devAmt  = (_total * 10) / 100; // 10%
        uint256 pubAmt  = _total - ceoAmt - prmAmt - devAmt; // 65%

        // Mint by assigning balances and emitting events
        balanceOf[ceo] += ceoAmt;
        emit Transfer(address(0), ceo, ceoAmt);

        balanceOf[promotion] += prmAmt;
        emit Transfer(address(0), promotion, prmAmt);

        balanceOf[devTeam] += devAmt;
        emit Transfer(address(0), devTeam, devAmt);

        balanceOf[publicCirculation] += pubAmt;
        emit Transfer(address(0), publicCirculation, pubAmt);
    }

    // --- ERC20 functions ---
    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        uint256 current = allowance[from][msg.sender];
        require(current >= value, "BIZ: allowance");
        unchecked { allowance[from][msg.sender] = current - value; }
        _transfer(from, to, value);
        return true;
    }

    // --- Internal transfer ---
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "BIZ: to zero");
        uint256 bal = balanceOf[from];
        require(bal >= value, "BIZ: balance");
        unchecked { balanceOf[from] = bal - value; }
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }
}
