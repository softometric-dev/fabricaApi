<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\PartnerDataModel;

class DeletePartnerResponseDataModel extends ApiResponseDataModel
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
		$deletePartnerResponseDataModel = new DeletePartnerResponseDataModel();
		if ($jsonData != null) {
			$deletedDealEnquiry = $jsonData->deletedDealEnquiry ?? null;
			if ($deletedDealEnquiry != null) {
				$partnerDataModel = PartnerDataModel::fromJson($deletedDealEnquiry);
				$deletePartnerResponseDataModel->deletedDealEnquiry = $partnerDataModel;
			}
		}
		return $deletePartnerResponseDataModel;
	}
}