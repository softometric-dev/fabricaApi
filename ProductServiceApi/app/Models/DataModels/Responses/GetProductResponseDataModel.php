<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\ProductDataModel;
use App\Models\Common\DataModels\CategoryDataModel;
use App\Models\Common\DataModels\BrandDataModel;


class GetProductResponseDataModel extends ApiResponseDataModel
{

    public $product;
    public $brand;
    public $category;
  
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
		$getProductResponseDataModel = new GetProductResponseDataModel();
		if ($jsonData != null) {

            $product = isset($jsonData->product) ? $jsonData->product : null;
			if ($product != null) {
				$productDataModel = ProductDataModel::fromJson($product);
				$getProductResponseDataModel->product = $productDataModel;
			}

            $brand = isset($jsonData->brand) ? $jsonData->brand : null;
			if ($brand != null) {
				$brandDataModel = BrandDataModel::fromJson($brand);
				$getProductResponseDataModel->brand = $brandDataModel;
			}

            $category = isset($jsonData->category) ? $jsonData->category : null;
			if ($category != null) {
				$categoryDataModel = CategoryDataModel::fromJson($category);
				$getProductResponseDataModel->category = $categoryDataModel;
			}

		}
		return $getProductResponseDataModel;
	}


}