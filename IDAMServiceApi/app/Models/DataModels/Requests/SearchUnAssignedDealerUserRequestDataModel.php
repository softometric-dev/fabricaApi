<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationRequestDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\DealerDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;
use App\Models\Common\DataModels\RoleDataModel;
use App\Models\Common\DataModels\CountryDataModel;
use App\Models\Common\DataModels\StateDataModel;

class SearchUnAssignedDealerUserRequestDataModel extends PaginationRequestDataModel
{
    public $userType;
    public $country;
	public $state;
	public $franchisee;		
	public $role;
	public $user;
	public $status;

    public function validateAndEnrichData()
	{
			$country = $this->country;
			$state = $this->state;
			$role = $this->role;
			$user = $this->user;
			$pagination = $this->pagination;
			//Validate mandatory inputs
			if( 
				((isNullOrEmpty($country) || 
				isNullOrEmpty($country->countryId)) &&
				(isNullOrEmpty($state) || 
				isNullOrEmpty($state->stateId)) &&
				(isNullOrEmpty($role) || 
				isNullOrEmpty($role->roleId)) &&
				(isNullOrEmpty($user) || 
				isNullOrEmpty($user->firstName) &&
				isNullOrEmpty($user->middleName) &&
				isNullOrEmpty($user->lastName) &&
				isNullOrEmpty($user->email))) ||
				isNullOrEmpty($pagination) ||
				isNullOrEmpty($pagination->currentPage) ||
				isNullOrEmpty($pagination->pageSize))
			{
				throw new ParameterException(MANDATORY_PARAMETER_ERROR,' countryId or stateId or roleId, or firstName or middleName or lastName or email. current page,page size');
			}		
			
			//Optional inputs and setting defaults	
	}

    public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$searchUnAssignedDealerUserRequestDataModel = new SearchUnAssignedDealerUserRequestDataModel();
		if ($jsonData != null) {
			

			$country = $jsonData->country ?? null;
			if ($country != null) {
				$countryDataModel = CountryDataModel::fromJson($country);
				$searchUnAssignedDealerUserRequestDataModel->country = $countryDataModel;
			}

			$state = $jsonData->state ?? null;
			if ($state != null) {
				$stateDataModel = StateDataModel::fromJson($state);
				$searchUnAssignedDealerUserRequestDataModel->state = $stateDataModel;
			}

			$role = $jsonData->role ?? null;
			if ($role != null) {
				$roleDataModel = RoleDataModel::fromJson($role);
				$searchUnAssignedDealerUserRequestDataModel->role = $roleDataModel;
			}


			$user = $jsonData->user ?? null;
			if ($user != null) {
				$userProfileDataModel = UserProfileDataModel::fromJson($user);
				$searchUnAssignedDealerUserRequestDataModel->user = $userProfileDataModel;
			}

			$pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$searchUnAssignedDealerUserRequestDataModel->pagination = $paginationDataModel;
			}
		}
		return $searchUnAssignedDealerUserRequestDataModel;
	}



}