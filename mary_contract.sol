pragma solidity ^0.4.19;

contract mary {

    function today(uint256 _i) private constant returns (uint256) {
      return now / 1 days + _i;
    }
    //婚約情報のストラクト
    struct Engagement {
        uint256 timestamp;
        address applicantAddress ;
        address authorizerAddress;
    }
    //全ての婚約情報
    Engagement [] public engagements;

    //婚約証明を作成しengagementsに格納
    function _createEngagement(uint256 _timestamp, address _applicantAddress,address _authorizerAddress) internal {
        engagements.push(Engagement(_timestamp,_applicantAddress,_authorizerAddress));
    }


    //アドレス(key)からその人が結婚申請をしたアドレス一覧(value)を収納・取得可能に
    mapping (address => address[]) public personalAddressToPartnerAddresses;


    //アドレス(key)からその人が結婚申請をしたアドレス一覧(value)を取得
    function getPartnerAddressesByPersonalAddress(address _personalAddress) public view returns (address[]) {
        return personalAddressToPartnerAddresses[_personalAddress];
    }

    //アドレス(key)をもとにその人が結婚申請をしたアドレス(value)を収納
    function setPartnerAddressByPertnerAddress (address _pertnerAddress) internal {
        personalAddressToPartnerAddresses[msg.sender].push(_pertnerAddress);
    }

    //アドレス(key)からその人が何回(uint256)結婚申請しているか取得
    function getProposeCountByPersonalAddress(address _personalAddress) public view returns (uint256){
       return personalAddressToPartnerAddresses[_personalAddress].length;
    }
     //その人が誰かに婚約申請済みかチェック
    function checkProposePersonalToSomeOne(address _personalAddress,address _someOneAddress) public view returns (bool){
       uint256 proposeCount = getProposeCountByPersonalAddress(_personalAddress);
       bool checkPropose = false;
       if(proposeCount == 0){
        }else{
            //proposeCountが１以上の場合
            address [] memory partnerAddresses = getPartnerAddressesByPersonalAddress(_personalAddress);
               //partnerAddressesからひとつずつ取り出して、_someOneAddressがないか確認する
               for (uint256 i = 1; i <= i+proposeCount && checkPropose == false; i++){
                   if(partnerAddresses[i-1] == _someOneAddress){
                       //partnerAddressesの中に_someOneAddressがあった場合
                       checkPropose = true;
                    }
                }
            }
        return checkPropose;
    }

    //結婚申請コントラクト
    function propose(address _pertnerAddress) external payable {

        //(自分から相手へ申請済みか、相手が自分に申請済みか)
        bool checkPersonalToPertner = checkProposePersonalToSomeOne(msg.sender,_pertnerAddress);
        bool checkPertnerToPersonal = checkProposePersonalToSomeOne(_pertnerAddress,msg.sender);

         //その相手に対して過去に申請していた場合は受け流す true,false
        if(checkPersonalToPertner == true && checkPertnerToPersonal == false){
            _pertnerAddress.transfer(msg.value);

        }//その相手が初めての申請の場合は登録する false,false
        else if(checkPersonalToPertner == false && checkPertnerToPersonal == false){
            setPartnerAddressByPertnerAddress(_pertnerAddress);
            _pertnerAddress.transfer(msg.value);

        }//逆にその相手が過去に自分に対して申請していた場合は婚約したとして婚約証明を作成 false,true
        else if(checkPersonalToPertner == false && checkPertnerToPersonal == true){
            uint256 timestamp = block.timestamp;
            _createEngagement(timestamp,_pertnerAddress,msg.sender);
            _pertnerAddress.transfer(msg.value);

        }//その上で既に婚約済みの場合は受け流す。true,true
        else if(checkPersonalToPertner == true && checkPertnerToPersonal == true){
            _pertnerAddress.transfer(msg.value);
        }
    }

}
