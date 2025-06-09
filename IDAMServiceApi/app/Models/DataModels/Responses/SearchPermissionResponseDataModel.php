<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationResponseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\PermissionDataModel;

class SearchPermissionResponseDataModel extends PaginationResponseDataModel
{
	public $permissions;
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
		$searchPermissionResponseDataModel = new SearchPermissionResponseDataModel();
		if ($jsonData != null) {
			$permissions = $jsonData->permissions ?? null;

			if ($permissions != null) {
				$searchPermissionResponseDataModel->permissions = array();
				foreach ($permissions as $permission) {
					$permissionDataModel = PermissionDataModel::fromJson($permission);
					$searchPermissionResponseDataModel->permissions[] = $permissionDataModel;
				}
			}
			$pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$searchPermissionResponseDataModel->pagination = $paginationDataModel;
			}
		}
		return $searchPermissionResponseDataModel;
	}

}
?>