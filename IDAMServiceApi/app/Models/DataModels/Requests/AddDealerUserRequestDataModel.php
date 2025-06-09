<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\DealerDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;

class AddDealerUserRequestDataModel extends ApiRequestDataModel
{

    public $dealer;
    public $users;

    public function __construct()
    {
			parent::__construct();
	}
    public function validateAndEnrichData()
	{
		$dealer = $this->dealer;
		$users = $this->users;			
			//Validate mandatory inputs
		if( isNullOrEmpty($dealer) ||
			isNullOrEmpty($users) ||
			isNullOrEmpty($dealer->dealerId)  || 
			isNullOrEmpty($users,array("userProfileId")) )
			{
				throw new ParameterException(MANDATORY_PARAMETER_ERROR,'dealerId, user profile id');
			}
			//Optional inputs and setting defaults		
	}

    public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$addDealerUserRequestDataModel = new AddDealerUserRequestDataModel();
		if ($jsonData != null) {
			$dealer = $jsonData->dealer ?? null;
			if ($dealer != null) {
				$dealerDataModel = DealerDataModel::fromJson($dealer);
				$addDealerUserRequestDataModel->dealer = $dealerDataModel;
			}

			$users = $jsonData->users ?? null;
			if($users != null && count($users) > 0)
				{
					foreach($users as $user)
					{
						$addDealerUserRequestDataModel->users[] = UserProfileDataModel::fromJson($user);	
					}
				}
		}
		return $addDealerUserRequestDataModel;
	}
}