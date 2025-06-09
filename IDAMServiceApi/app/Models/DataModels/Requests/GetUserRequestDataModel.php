<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;

class GetUserRequestDataModel extends ApiRequestDataModel
{
	public $user;
	public function __construct()
	{
		parent::__construct();
	}

	public function validateAndEnrichData()
	{
		$user = $this->user;

		// Validate mandatory inputs
		if (is_null($user) || is_null($user->userProfileId)) {
			throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'user profile id');
		}

		// Optional inputs and setting defaults
	}
	public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$getUserRequestDataModel = new GetUserRequestDataModel();
		if ($jsonData != null) {
			$user = $jsonData->user ?? null;
			if ($user != null) {
				$userProfileDataModel = UserProfileDataModel::fromJson($user);
				$getUserRequestDataModel->user = $userProfileDataModel;
			}
		}
		return $getUserRequestDataModel;
	}
}