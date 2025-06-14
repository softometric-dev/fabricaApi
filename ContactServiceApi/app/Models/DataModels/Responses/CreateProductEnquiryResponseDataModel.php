<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\ProductEnquiryDataModel;

class CreateProductEnquiryResponseDataModel extends ApiResponseDataModel
{
    public $newProductEnquiry;

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
		$createProductEnquiryResponseDataModel = new CreateProductEnquiryResponseDataModel();
		if ($jsonData != null) {
			$newProductEnquiry = $jsonData->newProductEnquiry ?? null;
			if ($newProductEnquiry != null) {
				$productEnquiryDataModel = ProductEnquiryDataModel::fromJson($newProductEnquiry);
				$createProductEnquiryResponseDataModel->newProductEnquiry = $productEnquiryDataModel;
			}



		}
		return $createProductEnquiryResponseDataModel;
	}

}