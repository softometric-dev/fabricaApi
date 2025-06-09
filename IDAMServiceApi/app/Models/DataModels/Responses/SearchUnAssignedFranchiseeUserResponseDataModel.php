<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationResponseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\UserDataModel;


class SearchUnAssignedFranchiseeUserResponseDataModel extends PaginationResponseDataModel
{
	public $users;
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
		$searchUnAssignedFranchiseeUserResponseDataModel = new SearchUnAssignedFranchiseeUserResponseDataModel();
		if ($jsonData != null) {
			$users = $jsonData->users ?? null;
			if ($users != null) {
				$searchUnAssignedFranchiseeUserResponseDataModel->users = array();
				foreach ($users as $user) {
					$userDataModel = UserDataModel::fromJson($user);
					$searchUnAssignedFranchiseeUserResponseDataModel->users[] = $userDataModel;
				}
			}
			$pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$searchUnAssignedFranchiseeUserResponseDataModel->pagination = $paginationDataModel;
			}
		}
		return $searchUnAssignedFranchiseeUserResponseDataModel;
	}

}