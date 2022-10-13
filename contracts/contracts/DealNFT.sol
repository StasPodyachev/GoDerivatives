import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "base64-sol/base64.sol";

contract DealNFT is ERC1155 {
    using Strings for uint256;

    uint constant DECIMAL = 18;
    uint public constant ONE = 10 ** DECIMAL;

    struct MintParams {
        uint256 dealId;
        uint256 deadline;
        uint256 amount;
        address market;
        address recipient;
        address buyer;
        address seller;
    }

    struct Holder {
        address addr;
        uint256 tokenId;
    }

    struct Deal {
        address buyer;
        address seller;
        address market;
        uint256 total;
        uint256 id;
        bool isBuyer;
    }

    mapping(uint256 => Deal) _deals;
    mapping(uint256 => address[]) _holders;

    constructor(string memory url) ERC1155(url) {}

    uint176 private _nextId = 1;

    modifier checkDeadline(uint256 deadline) {
        require(block.timestamp <= deadline, "Transaction too old");
        _;
    }

    function mint(MintParams calldata params)
        external
        payable
        checkDeadline(params.deadline)
        returns (uint256 tokenId)
    {
        _mint(params.recipient, (tokenId = _nextId++), ONE, "");

        _deals[tokenId] = Deal({
            id: params.dealId,
            total: params.amount,
            buyer: params.buyer,
            seller: params.seller,
            isBuyer: params.buyer == params.recipient,
            market: params.market
        });

        _holders[tokenId].push(params.recipient);
    }

    function getHolders(uint256 tokenId)
        external
        view
        returns (address[] memory holders_, uint[] memory balances)
    {

        address[] memory holders = _holders[tokenId];
        uint256 index = 0;
        for (uint256 i = 0; i < holders.length; i++) {
            balances[index] = balanceOf(holders[i], tokenId);
            if (balances[index] > 0){
                holders_[index++] = holders[i];
            }
        }
    }

    function burn(address from, uint256 id) external {
        uint256 amount = balanceOf(from, id);
        _burn(from, id, amount);

        delete _deals[id];
    }

    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override {
        if (from == address(0) || to == address(0)) return;

        for(uint i=0; i<ids.length; i++){
            _holders[ids[i]].push(to);
        }
    }

    function uri(uint256 id) public pure override returns (string memory) {
        string memory name = "Deal ETH/USDC";
        string memory description = string(
            abi.encodePacked("You are the owner of deal #", id.toString())
        );
        string
            memory image = "PHN2ZyB3aWR0aD0iODIiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCA4MiAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4NCjxwYXRoIGQ9Ik04LjcyODY5IDI0SDAuODQyMzNWMC43MjcyNzJIOC44ODc3OEMxMS4xOTg0IDAuNzI3MjcyIDEzLjE4MzIgMS4xOTMxOCAxNC44NDIzIDIuMTI1QzE2LjUwOSAzLjA0OTI0IDE3Ljc4OTMgNC4zNzg3OSAxOC42ODMyIDYuMTEzNjRDMTkuNTc3MiA3Ljg0ODQ4IDIwLjAyNDEgOS45MjQyNCAyMC4wMjQxIDEyLjM0MDlDMjAuMDI0MSAxNC43NjUyIDE5LjU3MzQgMTYuODQ4NSAxOC42NzE5IDE4LjU5MDlDMTcuNzc3OSAyMC4zMzMzIDE2LjQ4NjMgMjEuNjcwNSAxNC43OTY5IDIyLjYwMjNDMTMuMTE1MSAyMy41MzQxIDExLjA5MjMgMjQgOC43Mjg2OSAyNFpNNS4wNTgyNCAyMC4zNTIzSDguNTI0MTVDMTAuMTQ1NCAyMC4zNTIzIDExLjQ5NzYgMjAuMDU2OCAxMi41ODEgMTkuNDY1OUMxMy42NjQzIDE4Ljg2NzQgMTQuNDc4NyAxNy45NzczIDE1LjAyNDEgMTYuNzk1NUMxNS41Njk2IDE1LjYwNjEgMTUuODQyMyAxNC4xMjEyIDE1Ljg0MjMgMTIuMzQwOUMxNS44NDIzIDEwLjU2MDYgMTUuNTY5NiA5LjA4MzMzIDE1LjAyNDEgNy45MDkwOUMxNC40Nzg3IDYuNzI3MjcgMTMuNjcxOSA1Ljg0NDcgMTIuNjAzNyA1LjI2MTM2QzExLjU0MzEgNC42NzA0NSAxMC4yMjQ5IDQuMzc1IDguNjQ5MTUgNC4zNzVINS4wNTgyNFYyMC4zNTIzWk0yNC4wMjk4IDI0VjAuNzI3MjcySDM5LjE2NjJWNC4yNjEzNkgyOC4yNDU3VjEwLjU3OTVIMzguMzgyMVYxNC4xMTM2SDI4LjI0NTdWMjAuNDY1OUgzOS4yNTcxVjI0SDI0LjAyOThaTTQ2LjQ1NiAyNEg0MS45NTZMNTAuMTQ5MSAwLjcyNzI3Mkg1NS4zNTM3TDYzLjU1ODIgMjRINTkuMDU4Mkw1Mi44NDIzIDUuNUg1Mi42NjA1TDQ2LjQ1NiAyNFpNNDYuNjAzNyAxNC44NzVINTguODc2NFYxOC4yNjE0SDQ2LjYwMzdWMTQuODc1Wk02Ni42MjM2IDI0VjAuNzI3MjcySDcwLjgzOTVWMjAuNDY1OUg4MS4wODk1VjI0SDY2LjYyMzZaIiBmaWxsPSJibGFjayIvPg0KPC9zdmc+DQo=";

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name,
                                '",',
                                '"decimals": 18,',
                                '"description":"',
                                description,
                                '", "image": "',
                                "data:image/svg+xml;base64,",
                                image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
