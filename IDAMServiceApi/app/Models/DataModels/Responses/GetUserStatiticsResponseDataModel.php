<?php

namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationResponseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\StatisticsDataModel;

class GetUserStatiticsResponseDataModel extends PaginationResponseDataModel
{
	public $statitics;
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
		$getUserStatiticsResponseDataModel = new GetUserStatiticsResponseDataModel();
		if ($jsonData != null) {
			$statistics = $jsonData->statistics ?? null;
			if ($statistics != null) {
				$statiticsDataModel = StatiticsDataModel::fromJson($statistics);
				$getUserStatiticsResponseDataModel->statitics = $statiticsDataModel;
			}

			$pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$getUserStatiticsResponseDataModel->pagination = $paginationDataModel;
			}
		}
		return $getUserStatiticsResponseDataModel;
	}

}