<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationResponseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\UserDataModel;

class SearchUserResponseDataModel extends PaginationResponseDataModel
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
		$searchUserResponseDataModel = new SearchUserResponseDataModel();
		if ($jsonData != null) {
			$users = $jsonData->users ?? null;
			if ($users != null) {
				$searchUserResponseDataModel->users = array();
				foreach ($users as $user) {
					$userDataModel = UserDataModel::fromJson($user);
					$searchUserResponseDataModel->users[] = $userDataModel;
				}
			}
			$pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$searchUserResponseDataModel->pagination = $paginationDataModel;
			}
		}
		return $searchUserResponseDataModel;
	}

}