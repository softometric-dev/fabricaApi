<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\ProductDataModel;

class CreateProductResponseDataModel extends ApiResponseDataModel
{
    public $newProduct;

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
		$createProductResponseDataModel = new CreateProductResponseDataModel();
		if ($jsonData != null) {
			$newProduct = $jsonData->newProduct ?? null;
			if ($newProduct != null) {
				$productDataModel = ProductDataModel::fromJson($newProduct);
				$createProductResponseDataModel->newProduct = $productDataModel;
			}


		}
		return $createProductResponseDataModel;
	}

}