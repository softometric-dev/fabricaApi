<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\RoleDataModel;

class DeleteRoleRequestDataModel extends ApiRequestDataModel
{
	public $roleToDelete;
	public function __construct()
	{
		parent::__construct();
	}

	public function validateAndEnrichData()
	{
		$roleToDelete = $this->roleToDelete;

		// Validate mandatory inputs
		if (
			is_null($roleToDelete) ||
			(is_null($roleToDelete->roleId) && is_null($roleToDelete->roleName))
		) {
			throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'roleId or roleName');
		}

		// Optional inputs and setting defaults
	}

	public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$deleteRoleRequestDataModel = new DeleteRoleRequestDataModel();
		if ($jsonData != null) {
			$roleToDelete = $jsonData->roleToDelete ?? null;
			if ($roleToDelete != null) {
				$roleDataModel = RoleDataModel::fromJson($roleToDelete);
				$deleteRoleRequestDataModel->roleToDelete = $roleDataModel;
			}
		}
		return $deleteRoleRequestDataModel;
	}
}