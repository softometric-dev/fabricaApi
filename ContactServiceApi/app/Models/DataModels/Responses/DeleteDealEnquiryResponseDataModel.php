<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\DealEnquiryDataModel;

class DeleteDealEnquiryResponseDataModel extends ApiResponseDataModel
{
    public $deletedDealEnquiry;
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
		$deleteDealEnquiryResponseDataModel = new DeleteDealEnquiryResponseDataModel();
		if ($jsonData != null) {
			$deletedDealEnquiry = $jsonData->deletedDealEnquiry ?? null;
			if ($deletedDealEnquiry != null) {
				$dealEnquiryDataModel = DealEnquiryDataModel::fromJson($deletedDealEnquiry);
				$deleteDealEnquiryResponseDataModel->deletedDealEnquiry = $dealEnquiryDataModel;
			}
		}
		return $deleteDealEnquiryResponseDataModel;
	}
}