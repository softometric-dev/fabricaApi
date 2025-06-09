<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationRequestDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
// use App\Models\Common\DataModels\FranchiseeDataModel;
use App\Models\Common\DataModels\DealerDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;
use App\Models\Common\DataModels\UserTypeDataModel;
use App\Models\Common\DataModels\RoleDataModel;
use App\Models\Common\DataModels\CountryDataModel;
use App\Models\Common\DataModels\StateDataModel;
use App\Models\Common\DataModels\StatusDataModel;


class SearchUserRequestDataModel extends PaginationRequestDataModel
{

	public $userType;
	public $country;
	public $state;
	public $franchisee;
	public $role;
	public $user;
	public $status;
	public $dealer;
	public $salesExecutiveId;
	public function __construct()
	{
		parent::__construct();
	}

	public function validateAndEnrichData()
	{
		$userType = $this->userType;
		
		$country = $this->country;
		$state = $this->state;
		// $franchisee = $this->franchisee;
		$role = $this->role;
		$user = $this->user;
		$status = $this->status;
		$pagination = $this->pagination;
		$dealer = $this->dealer;
		$salesExecutiveId = $this->salesExecutiveId;

	
		// Validate mandatory inputs
	
		if (
			
			(empty($userType) || empty($userType->userTypeId)) &&
			(empty($country) || empty($country->countryId)) &&
			(empty($state) || empty($state->stateId)) &&
			(empty($dealer) || empty($dealer->dealerId)) &&
			(empty($role) || empty($role->roleId)) &&
			(empty($status) || empty($status->statusId)) &&
			(empty($user) || (empty($user->firstName) && empty($user->middleName) && empty($user->lastName) && empty($user->email))) ||
			empty($pagination) ||
			empty($pagination->currentPage) ||
			empty($pagination->pageSize)
		) {
			throw new ParameterException(MANDATORY_PARAMETER_ERROR, ' userTypeId or  countryId or stateId or roleId, or firstName or middleName or lastName or email or user status id. current page,page size');
		}
	}

	public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$searchUserRequestDataModel = new SearchUserRequestDataModel();
		if ($jsonData != null) {
			
			$salesExecutiveId = $jsonData->salesExecutiveId ?? null;
			$searchUserRequestDataModel->salesExecutiveId = $salesExecutiveId;

			$userType = $jsonData->userType ?? null;
			if ($userType != null) {
				$userTypeDataModel = UserTypeDataModel::fromJson($userType);
				$searchUserRequestDataModel->userType = $userTypeDataModel;
			}

			$country = $jsonData->country ?? null;
			if ($country != null) {
				$countryDataModel = CountryDataModel::fromJson($country);
				$searchUserRequestDataModel->country = $countryDataModel;
			}

			$state = $jsonData->state ?? null;
			if ($state != null) {
				$stateDataModel = StateDataModel::fromJson($state);
				$searchUserRequestDataModel->state = $stateDataModel;
			}

			$dealer = isset($jsonData->dealer) ? $jsonData->dealer : null;	
			if($dealer != null )
			{					
				$dealerDataModel = DealerDataModel::fromJson($dealer);					
				$searchUserRequestDataModel->dealer = $dealerDataModel;	
			}

			$role = $jsonData->role ?? null;
			if ($role != null) {
				$roleDataModel = RoleDataModel::fromJson($role);
				$searchUserRequestDataModel->role = $roleDataModel;
			}

			$status = $jsonData->status ?? null;
			if ($status != null) {
				$statusDataModel = StatusDataModel::fromJson($status);
				$searchUserRequestDataModel->status = $statusDataModel;
			}

			$user = $jsonData->user ?? null;
			if ($user != null) {
				$userProfileDataModel = UserProfileDataModel::fromJson($user);
				$searchUserRequestDataModel->user = $userProfileDataModel;
			}

			$pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$searchUserRequestDataModel->pagination = $paginationDataModel;
			}
		}
		return $searchUserRequestDataModel;
	}

}