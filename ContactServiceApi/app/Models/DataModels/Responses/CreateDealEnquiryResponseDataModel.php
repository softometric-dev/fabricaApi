<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\PartnerDataModel;

class CreateDealEnquiryResponseDataModel extends ApiResponseDataModel
{
    public $newDealEnquiry;

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
		$createDealEnquiryResponseDataModel = new CreateDealEnquiryResponseDataModel();
		if ($jsonData != null) {
			$newDealEnquiry = $jsonData->newDealEnquiry ?? null;
			if ($newDealEnquiry != null) {
				$dealEnquiryDataModel = DealEnquiryDataModel::fromJson($newDealEnquiry);
				$createDealEnquiryResponseDataModel->newDealEnquiry = $dealEnquiryDataModel;
			}



		}
		return $createDealEnquiryResponseDataModel;
	}

}