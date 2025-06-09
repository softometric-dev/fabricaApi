<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationResponseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\RoleDataModel;


class GetAllUserRolesResponseDataModel extends PaginationResponseDataModel
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
		$getAllUserRolesResponseDataModel = new GetAllUserRolesResponseDataModel();
		if ($jsonData != null) {
			$roles = $jsonData->roles ?? null;
			if ($roles != null) {
				$getAllUserRolesResponseDataModel->roles = array();
				foreach ($roles as $role) {
					$roleDataModel = RoleDataModel::fromJson($roles);
					$getAllUserRolesResponseDataModel->roles[] = $roleDataModel;
				}
			}
			$pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$getAllUserRolesResponseDataModel->pagination = $paginationDataModel;
			}
		}
		return $getAllUserRolesResponseDataModel;
	}

}