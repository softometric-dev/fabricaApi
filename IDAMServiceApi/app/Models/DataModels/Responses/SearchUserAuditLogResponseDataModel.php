<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationResponseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\UserAuditLogDataModel;

class SearchUserAuditLogResponseDataModel extends PaginationResponseDataModel
{
	public $userAuditLogs;
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
		$searchUserAuditLogResponseDataModel = new SearchUserAuditLogResponseDataModel();
		if ($jsonData != null) {
			$userAuditLogs = $jsonData->userAuditLogs ?? null;
			if ($userAuditLogs != null) {
				$searchUserAuditLogResponseDataModel->userAuditLogs = array();
				foreach ($userAuditLogs as $userAuditLog) {
					$userAuditLogDataModel = UserAuditLogDataModel::fromJson($userAuditLog);
					$searchUserAuditLogResponseDataModel->userAuditLogs[] = $userAuditLogDataModel;
				}
			}
			$pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$searchUserAuditLogResponseDataModel->pagination = $paginationDataModel;
			}
		}
		return $searchUserAuditLogResponseDataModel;
	}

}