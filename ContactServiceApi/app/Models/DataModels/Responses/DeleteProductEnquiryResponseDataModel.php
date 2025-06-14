<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\ProductEnquiryDataModel;

class DeleteProductEnquiryResponseDataModel extends ApiResponseDataModel
{
    public $deletedProductEnquiry;
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
		$deleteProductEnquiryResponseDataModel = new DeleteProductEnquiryResponseDataModel();
		if ($jsonData != null) {
			$deletedProductEnquiry = $jsonData->deletedProductEnquiry ?? null;
			if ($deletedProductEnquiry != null) {
				$productEnquiryDataModel = ProductEnquiryDataModel::fromJson($deletedProductEnquiry);
				$deleteProductEnquiryResponseDataModel->deletedProductEnquiry = $productEnquiryDataModel;
			}
		}
		return $deleteProductEnquiryResponseDataModel;
	}
}