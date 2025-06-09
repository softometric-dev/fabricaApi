<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\DealerDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;

class AddDealerUserResponseDataModel extends ApiResponseDataModel
{
    public $dealer;
    public $users;
    public function __construct()
        {
			parent::__construct();
		}

		public function validateAndEnrichData()
		{
			//Validate mandatory inputs
						
			//Optional inputs and setting defaults			
			
		}

    public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$addDealerUserResponseDataModel = new AddDealerUserResponseDataModel();
		if ($jsonData != null) {
			$dealer = $jsonData->dealer ?? null;
			if ($dealer != null) {
				$dealerDataModel = DealerDataModel::fromJson($dealer);
				$addDealerUserResponseDataModel->dealer = $dealerDataModel;
			}

			$users = $jsonData->users ?? null;
			if ($users != null) {
                $userProfileDataModel = UserProfileDataModel::fromJson($users);		
				$addDealerUserResponseDataModel->users = $userProfileDataModel;
			}
		}
		return $addDealerUserResponseDataModel;
	}
}