<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\RoleDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;

class AddUserRolesRequestDataModel extends ApiRequestDataModel
{

	public $user;
	public $roles = [];
	public function __construct()
	{
		parent::__construct();
	}

	public function validateAndEnrichData()
	{
		$user = $this->user;
		$roles = $this->roles;

		// Validate mandatory inputs
		if (
			is_null($user) ||
			is_null($roles) ||
			is_null($user->userProfileId) ||
			empty(array_filter($roles, fn($role) => isset ($role->roleId)))
		) {
			throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'user profile id, role id');
		}

		// Optional inputs and setting defaults (if any)
	}

	public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$addUserRolesRequestDataModel = new AddUserRolesRequestDataModel();
		if ($jsonData != null) {
			$user = $jsonData->user ?? null;
			if ($user != null) {
				$userProfileDataModel = UserProfileDataModel::fromJson($user);
				$addUserRolesRequestDataModel->user = $userProfileDataModel;
			}

			$roles = $jsonData->roles ?? null;
			if ($roles != null && count($roles) > 0) {
				foreach ($roles as $role) {
					$addUserRolesRequestDataModel->roles[] = RoleDataModel::fromJson($role);
				}
			}
		}
		return $addUserRolesRequestDataModel;
	}
}

