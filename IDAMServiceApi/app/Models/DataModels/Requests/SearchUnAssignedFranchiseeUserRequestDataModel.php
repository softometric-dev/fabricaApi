<?php

namespace App\Models\DataModels\Requests;
use App\Libraries\{ParameterException};

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationRequestDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\RoleDataModel;
use App\Models\Common\DataModels\CountryDataModel;
use App\Models\Common\DataModels\StateDataModel;
use App\Models\Common\DataModels\UserProfileDataModel;

class SearchUnAssignedFranchiseeUserRequestDataModel extends PaginationRequestDataModel
{

    public $userType;
    public $country;
    public $state;
    public $franchisee;
    public $role;
    public $user;
    public $status;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $country = $this->country;
        $state = $this->state;
        $role = $this->role;
        $user = $this->user;
        $pagination = $this->pagination;

        // Validate mandatory inputs
        if (
            (
                (empty($country) || empty($country->countryId)) &&
                (empty($state) || empty($state->stateId)) &&
                (empty($role) || empty($role->roleId)) &&
                (empty($user) || (
                    empty($user->firstName) &&
                    empty($user->middleName) &&
                    empty($user->lastName) &&
                    empty($user->email)
                ))
            ) ||
            empty($pagination) ||
            empty($pagination->currentPage) ||
            empty($pagination->pageSize)
        ) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'countryId or stateId or roleId, or firstName or middleName or lastName or email. Current page, page size');
        }
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $searchUnAssignedFranchiseeUserRequestDataModel = new SearchUnAssignedFranchiseeUserRequestDataModel();
        if ($jsonData != null) {
            $country = $jsonData->country ?? null;
            if ($country != null) {
                $countryDataModel = CountryDataModel::fromJson($country);
                $searchUnAssignedFranchiseeUserRequestDataModel->country = $countryDataModel;
            }

            $state = $jsonData->state ?? null;
            if ($state != null) {
                $stateDataModel = StateDataModel::fromJson($state);
                $searchUnAssignedFranchiseeUserRequestDataModel->state = $stateDataModel;
            }

            $role = $jsonData->role ?? null;
            if ($role != null) {
                $roleDataModel = RoleDataModel::fromJson($role);
                $searchUnAssignedFranchiseeUserRequestDataModel->role = $roleDataModel;
            }

            $user = $jsonData->user ?? null;
            if ($user != null) {
                $userProfileDataModel = UserProfileDataModel::fromJson($user);
                $searchUnAssignedFranchiseeUserRequestDataModel->user = $userProfileDataModel;
            }

            $pagination = $jsonData->pagination ?? null;
            if ($pagination != null) {
                $paginationDataModel = PaginationDataModel::fromJson($pagination);
                $searchUnAssignedFranchiseeUserRequestDataModel->pagination = $paginationDataModel;
            }
        }
        return $searchUnAssignedFranchiseeUserRequestDataModel;
    }

}