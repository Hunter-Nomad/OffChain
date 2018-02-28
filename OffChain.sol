pragma solidity ^0.4.19;

contract OffChain{
    
    address owner; // адрес владельца контракта
    
    struct borrower{ // структура заемщиков
        uint8 loopLoanOfMoney; // номер транзакции, если возврат частями
        uint loanAmount; // сумма займа
        uint loanBalance; // остаток по займу
        uint setLoanBalance; // взнос по последней транзакции
        uint8 _status; // статус займа. 0 - заявка подана, 1 - займ выдан, 2 - займ возвращен
    }
    
    // событие по запросу займа
    event LoanOfMoney(address _address, uint loanAmount);
    
    // мапинг заемщиков
    mapping(address => borrower) borrowers; 
    
    // модификатор признака владельца контракта
	modifier isOwner {
	    require(owner == msg.sender);
	    _;
	}
	
    // конструктор
    function OffChain() public{
        owner = msg.sender;
    }
    
    // заявка на займ денег
    function loanOfMoney(uint _loanAmount) public{
        if(borrowers[msg.sender]._status == 0){
            borrowers[msg.sender].loanAmount = _loanAmount; //сумма займа
            borrowers[msg.sender]._status = 0; // статус "заявка подана"
            LoanOfMoney(msg.sender, _loanAmount);
        }
    }
    
    // проверить состояние займа
    function getBalance(address _address) public view returns(uint8, uint, uint, uint, string){
        if(owner == msg.sender){
            if(borrowers[_address]._status == 0){
                return (borrowers[_address].loopLoanOfMoney, borrowers[_address].loanAmount, borrowers[_address].loanBalance, borrowers[_address].setLoanBalance, "Займ не выдан, или на рассмотрении");
            }
            if(borrowers[_address]._status == 1){
                return (borrowers[_address].loopLoanOfMoney, borrowers[_address].loanAmount, borrowers[_address].loanBalance, borrowers[_address].setLoanBalance, "Займ выдан, но не погашен");
            }
            if(borrowers[_address]._status == 2){
                return (borrowers[_address].loopLoanOfMoney, borrowers[_address].loanAmount, borrowers[_address].loanBalance, borrowers[_address].setLoanBalance, "Займ погашен");
            }
        } else {
            if(borrowers[msg.sender]._status == 0){
                return (borrowers[msg.sender].loopLoanOfMoney, borrowers[msg.sender].loanAmount, borrowers[msg.sender].loanBalance, borrowers[msg.sender].setLoanBalance, "Займ не выдан, или на рассмотрении");
            }
            if(borrowers[msg.sender]._status == 1){
                return (borrowers[msg.sender].loopLoanOfMoney, borrowers[msg.sender].loanAmount, borrowers[msg.sender].loanBalance, borrowers[msg.sender].setLoanBalance, "Займ выдан, но не погашен");
            }
            if(borrowers[msg.sender]._status == 2){
                return (borrowers[msg.sender].loopLoanOfMoney, borrowers[msg.sender].loanAmount, borrowers[msg.sender].loanBalance, borrowers[msg.sender].setLoanBalance, "Займ погашен");
            }
        }
    }
  
    // установление стастуса займа или погашение долга по займу
    function setBalance(address _address, uint _setLoanBalance) public isOwner{
        if(_setLoanBalance != 0){
            borrowers[_address].loanBalance += _setLoanBalance; // пополнение суммы по долгу
            borrowers[_address].setLoanBalance = _setLoanBalance; // взнос по последней транзакции
            borrowers[_address].loopLoanOfMoney += 1; // номер транзакции по долгу
        }
        if(borrowers[_address].loanAmount == borrowers[_address].loanBalance){
            borrowers[_address].loanAmount = 0; // обнудение суммы займа
            borrowers[_address].loanBalance = 0; // обнудение долга по займу
            borrowers[_address].setLoanBalance = 0; // обнудение последнего взноса
            borrowers[_address].loopLoanOfMoney = 0; // обнудение номера транзакции
            borrowers[_address]._status = 2; // статус "займ возвращен"
        }
        if(_setLoanBalance == 0 && borrowers[_address]._status == 0){
            borrowers[_address]._status = 1; // статус "займ выдан"
        }
    }
    
    // уничтожение контракта
	function kill() public isOwner {
		selfdestruct(owner);
	}
}
