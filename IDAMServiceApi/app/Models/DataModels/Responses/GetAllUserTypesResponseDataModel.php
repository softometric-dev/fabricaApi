<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationResponseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\UserTypeDataModel;

class GetAllUserTypesResponseDataModel extends PaginationResponseDataModel
{
	public $userTypes;
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
		$getAllUserTypesResponseDataModel = new GetAllUserTypesResponseDataModel();
		if ($jsonData != null) {
			$userTypes = $jsonData->userTypes ?? null;
			if ($userTypes != null) {
				$getAllUserTypesResponseDataModel->userTypes = array();
				foreach ($userTypes as $userType) {
					$userTypeDataModel = UserTypeDataModel::fromJson($userType);
					$getAllUserTypesResponseDataModel->userTypes[] = $userTypeDataModel;
				}
			}
			$pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$getAllUserTypesResponseDataModel->pagination = $paginationDataModel;
			}
		}
		return $getAllUserTypesResponseDataModel;
	}

}