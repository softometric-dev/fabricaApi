<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\ProductDataModel;

class DeleteProductResponseDataModel extends ApiResponseDataModel
{
    public $deletedProduct;
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
		$deleteProductResponseDataModel = new DeleteProductResponseDataModel();
		if ($jsonData != null) {
			$deletedProduct = $jsonData->deletedProduct ?? null;
			if ($deletedProduct != null) {
				$productDataModel = ProductDataModel::fromJson($deletedProduct);
				$deleteProductResponseDataModel->deletedProduct = $productDataModel;
			}
		}
		return $deleteProductResponseDataModel;
	}
}