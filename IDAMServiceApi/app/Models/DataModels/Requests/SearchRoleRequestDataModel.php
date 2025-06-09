<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationRequestDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\UserTypeDataModel;
use App\Models\Common\DataModels\RoleDataModel;

class SearchRoleRequestDataModel extends PaginationRequestDataModel
{
	public $userType;
	public function __construct()
	{
		parent::__construct();
	}
	public function validateAndEnrichData()
	{
		$userType = $this->userType;
		$pagination = $this->pagination;

		// Validate mandatory inputs
		if (
			(empty($userType) ||
				(empty($userType->userTypeId) && empty($userType->userType))) ||
			empty($pagination) ||
			empty($pagination->currentPage) ||
			empty($pagination->pageSize)
		) {
			throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'userTypeId or userType and current page, page size');
		}

		// Optional inputs and setting defaults
	}

	public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$searchRoleRequestDataModel = new SearchRoleRequestDataModel();
		if ($jsonData != null) {
			$userType = $jsonData->userType ?? null;
			if ($userType != null) {
				$userTypeDataModel = UserTypeDataModel::fromJson($userType);
				$searchRoleRequestDataModel->userType = $userTypeDataModel;
			}

			$pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$searchRoleRequestDataModel->pagination = $paginationDataModel;
			}
		}
		return $searchRoleRequestDataModel;
	}
}