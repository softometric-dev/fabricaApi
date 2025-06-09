<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;

class GetUserPermissionsRequestDataModel extends ApiRequestDataModel
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
		if (
			is_null($user) ||
			(is_null($user->userProfileId) && is_null($user->email))
		) {
			throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'userProfileId or email');
		}

		// Optional inputs and setting defaults
	}

	public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$getUserPermissionsRequestDataModel = new GetUserPermissionsRequestDataModel();
		if ($jsonData != null) {
			$user = $jsonData->user ?? null;
			if ($user != null) {
				$userProfileDataModel = UserProfileDataModel::fromJson($user);
				$getUserPermissionsRequestDataModel->user = $userProfileDataModel;
			}
		}
		return $getUserPermissionsRequestDataModel;
	}
}