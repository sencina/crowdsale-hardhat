pragma solidity 0.5.5;

import "@openzeppelin/contracts/token/ERC20/ERC20Mintable.sol";

contract MusiTokenRefundableCrowdsale{


    /*
    default constructor parameters
     */

    address public beneficiary;
    uint public fundingGoal;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    ERC20Mintable public musitoken;

    /*
    Adresses variables
    */

    mapping (address => uint256) public balanceOf;
    address[] public owners;

    /*
    Goal reach variables
    */

     bool fundingGoalReached = false;
     bool crowdsaleClosed = false;
    
    /*
    events for goal 
    */

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    constructor(
        address ifSuccesfulSendTo,
        uint fundingGoalInMatic,
        uint durationInMinutes,
        uint costOfEachTokenInMatic,
        ERC20Mintable _token
    )
    public
    {
        beneficiary = ifSuccesfulSendTo;
        fundingGoal = fundingGoalInMatic;
        amountRaised = 0;
        deadline = now + durationInMinutes * 1 minutes;
        price = costOfEachTokenInMatic;
        musitoken = _token;
    }

    function () payable external {
        require(!crowdsaleClosed);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        addOwner(msg.sender);
        amountRaised += amount;

        emit FundTransfer(msg.sender, amount, true);
    }

    function checkGoalReached() public afterDeadline{

        if(amountRaised >= fundingGoal){
            fundingGoalReached = true;
            emit GoalReached(beneficiary, amountRaised);
        }

    }

    function safeWithdrawl() public afterDeadline{
        if(!fundingGoalReached){
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;

            if(amount > 0) {
                if(msg.sender.send(amount)){
                    emit FundTransfer(msg.sender, amount, false);
                }else{
                    balanceOf[msg.sender] = amount;
                }
            }
        }

        if(fundingGoalReached && beneficiary == msg.sender){
            if(msg.sender.send(amountRaised)){
                emit FundTransfer(beneficiary, amountRaised, false);
            }else{
                fundingGoalReached = false;
            }
        }
    }


    /*
    MODIFIERS 
    */

    modifier afterDeadline(){
        if(now >= deadline) _;
    }

    /*
    INTERNAL FUNCTIONS
     */

    function addOwner (address newOwner) internal{
        
        bool foundOwner = false;

        for (uint256 index = 0; index < owners.length; index++) {
            if (newOwner == owners[index]){
                foundOwner = true;
            }
        }

        if (!foundOwner){
            owners.push(newOwner);
        }

    }


    function mintTokens() internal {
        
    }

}