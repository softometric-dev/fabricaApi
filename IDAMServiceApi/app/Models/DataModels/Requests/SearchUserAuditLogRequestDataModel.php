<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationRequestDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;
use App\Models\Common\DataModels\UserTypeDataModel;
use App\Models\Common\DataModels\RoleDataModel;
use App\Models\Common\DataModels\CountryDataModel;
use App\Models\Common\DataModels\StateDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\StatusDataModel;


class SearchUserAuditLogRequestDataModel extends PaginationRequestDataModel
{

	public $user;
	public $status;

	public function __construct()
	{
		parent::__construct();
	}

	public function validateAndEnrichData()
	{
		$user = $this->user;
		$status = $this->status;
		$pagination = $this->pagination;

		// Validate mandatory inputs
		if (
			empty($pagination) ||
			empty($pagination->currentPage) ||
			empty($pagination->pageSize)
		) {
			throw new ParameterException('Mandatory parameters missing: current page, page size');
		}
	}

	public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$searchUserAuditLogRequestDataModel = new SearchUserAuditLogRequestDataModel();
		if ($jsonData != null) {

			// $franchisee = isset($jsonData->franchisee) ? $jsonData->franchisee : null;	
			// if($franchisee != null )
			// {					
			// 	$franchiseeDataModel = FranchiseeDataModel::fromJson($franchisee);					
			// 	$searchUserAuditLogRequestDataModel->franchisee = $franchiseeDataModel;	
			// }

			$status = $jsonData->status ?? null;
			if ($status != null) {
				$statusDataModel = StatusDataModel::fromJson($status);
				$searchUserAuditLogRequestDataModel->status = $statusDataModel;
			}

			$user = $jsonData->user ?? null;
			if ($user != null) {
				$userProfileDataModel = UserProfileDataModel::fromJson($user);
				$searchUserAuditLogRequestDataModel->user = $userProfileDataModel;
			}

			$pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$searchUserAuditLogRequestDataModel->pagination = $paginationDataModel;
			}
		}
		return $searchUserAuditLogRequestDataModel;
	}

}