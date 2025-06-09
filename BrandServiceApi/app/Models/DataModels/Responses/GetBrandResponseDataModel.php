<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\BrandDataModel;
use App\Models\Common\DataModels\CategoryDataModel;


class GetBrandResponseDataModel extends ApiResponseDataModel
{

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
		$getBrandResponseDataModel = new GetBrandResponseDataModel();
		if ($jsonData != null) {

            $brand = isset($jsonData->brand) ? $jsonData->brand : null;
			if ($brand != null) {
				$brandDataModel = BrandDataModel::fromJson($brand);
				$getBrandResponseDataModel->brand = $brandDataModel;
			}

            $category = $jsonData->category ?? null;
			if ($category != null) {
				$categoryDataModel = CategoryDataModel::fromJson($category);
				$getBrandResponseDataModel->category = $categoryDataModel;
			}


		}
		return $getBrandResponseDataModel;
	}


}