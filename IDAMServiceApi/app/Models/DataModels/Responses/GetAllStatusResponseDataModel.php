<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationResponseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\StatusDataModel;


class GetAllStatusResponseDataModel extends PaginationResponseDataModel
{
	public $statuses;
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
		$getAllStatusResponseDataModel = new GetAllStatusResponseDataModel();
		if ($jsonData != null) {
			$statuses = $jsonData->statuses ?? null;
			if ($statuses != null) {
				$getAllStatusResponseDataModel->statuses = array();
				foreach ($statuses as $status) {
					$statusDataModel = StatusDataModel::fromJson($status);
					$getAllStatusResponseDataModel->statuses[] = $statusDataModel;
				}
			}
			$pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$getAllStatusResponseDataModel->pagination = $paginationDataModel;
			}
		}
		return $getAllStatusResponseDataModel;
	}

}