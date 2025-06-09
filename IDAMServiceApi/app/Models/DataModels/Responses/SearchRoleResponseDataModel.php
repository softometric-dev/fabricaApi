<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationResponseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\RoleDataModel;

class SearchRoleResponseDataModel extends PaginationResponseDataModel
{
	public $roles;
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
		$searchRoleResponseDataModel = new SearchRoleResponseDataModel();
		if ($jsonData != null) {
			$roles = $jsonData->roles ?? null;
			if ($roles != null) {
				$searchRoleResponseDataModel->roles = array();
				foreach ($roles as $role) {
					$roleDataModel = RoleDataModel::fromJson($role);
					$searchRoleResponseDataModel->roles[] = $roleDataModel;
				}
			}
			$pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$searchRoleResponseDataModel->pagination = $paginationDataModel;
			}
		}
		return $searchRoleResponseDataModel;
	}

}
?>