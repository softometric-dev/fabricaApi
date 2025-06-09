<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\PermissionDataModel;

class DeletePermissionRequestDataModel extends ApiRequestDataModel
{

	public $permissionToDelete;
	public function __construct()
	{
		parent::__construct();
	}

	public function validateAndEnrichData()
	{
		$permissionToDelete = $this->permissionToDelete;

		// Validate mandatory inputs
		if (
			is_null($permissionToDelete) ||
			(is_null($permissionToDelete->permissionId) && is_null($permissionToDelete->permissionName))
		) {
			throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'permissionId or permissionName');
		}

		// Optional inputs and setting defaults
	}

	public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$deletePermissionRequestDataModel = new DeletePermissionRequestDataModel();
		if ($jsonData != null) {
			$permissionToDelete = $jsonData->permissionToDelete ?? null;
			if ($permissionToDelete != null) {
				$permissionDataModel = PermissionDataModel::fromJson($permissionToDelete);
				$deletePermissionRequestDataModel->permissionToDelete = $permissionDataModel;
			}
		}
		return $deletePermissionRequestDataModel;
	}
}