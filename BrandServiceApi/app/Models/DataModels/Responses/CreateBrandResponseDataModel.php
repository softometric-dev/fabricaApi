<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\BrandDataModel;

class CreateBrandResponseDataModel extends ApiResponseDataModel
{
    public $newBrand;

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
		$createBrandResponseDataModel = new CreateBrandResponseDataModel();
		if ($jsonData != null) {
			$newBrand = $jsonData->newBrand ?? null;
			if ($newBrand != null) {
				$brandDataModel = BrandDataModel::fromJson($newBrand);
				$createBrandResponseDataModel->newBrand = $brandDataModel;
			}



		}
		return $createBrandResponseDataModel;
	}

}