<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\BrandDataModel;

class DeleteBrandResponseDataModel extends ApiResponseDataModel
{
    public $deletedBrand;
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
		$deleteBrandResponseDataModel = new DeleteBrandResponseDataModel();
		if ($jsonData != null) {
			$deletedBrand = $jsonData->deletedBrand ?? null;
			if ($deletedBrand != null) {
				$brandDataModel = BrandDataModel::fromJson($deletedBrand);
				$deleteBrandResponseDataModel->deletedBrand = $brandDataModel;
			}
		}
		return $deleteBrandResponseDataModel;
	}
}