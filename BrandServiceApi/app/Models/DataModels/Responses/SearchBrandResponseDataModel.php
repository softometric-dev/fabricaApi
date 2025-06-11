<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationResponseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\BrandDataModel;
use App\Models\Common\DataModels\CategoryDataModel;

class SearchBrandResponseDataModel extends PaginationResponseDataModel
{

    public $brands;
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
		$searchBrandResponseDataModel = new SearchBrandResponseDataModel();
		if ($jsonData != null) {

            $brands = $jsonData->brands ?? null;
			if ($brands != null) {
				$searchBrandResponseDataModel->brands = array();
				foreach ($brands as $brand) {
					$brandDataModel = BrandDataModel::fromJson($brand);
					$searchBrandResponseDataModel->brands[] = $brandDataModel;
				}
			}
		
			$category = $jsonData->category ?? null;
			if ($category != null) {
				$categoryDataModel = CategoryDataModel::fromJson($category);
				$searchBrandResponseDataModel->category = $categoryDataModel;
			}

			
            $pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$searchBrandResponseDataModel->pagination = $paginationDataModel;
			}
		}
		return $searchBrandResponseDataModel;
	}

}