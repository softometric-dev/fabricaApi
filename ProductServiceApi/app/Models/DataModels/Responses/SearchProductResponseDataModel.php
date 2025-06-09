<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationResponseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\ProductDataModel;
use App\Models\Common\DataModels\CategoryDataModel;
use App\Models\Common\DataModels\BrandDataModel;

class SearchProductResponseDataModel extends PaginationResponseDataModel
{

    public $products;
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
		$searchProductResponseDataModel = new SearchProductResponseDataModel();
		if ($jsonData != null) {

            $products = $jsonData->products ?? null;
			if ($products != null) {
				$searchProductResponseDataModel->products = array();
				foreach ($products as $product) {
					$productDataModel = ProductDataModel::fromJson($products);
					$searchProductResponseDataModel->products[] = $productDataModel;
				}
			}
		
			$brand = $jsonData->brand ?? null;
			if ($brand != null) {
				$brandDataModel = BrandDataModel::fromJson($brand);
				$searchProductResponseDataModel->brand = $brandDataModel;
			}

            $category = $jsonData->category ?? null;
			if ($category != null) {
				$categoryDataModel = CategoryDataModel::fromJson($category);
				$searchProductResponseDataModel->category = $categoryDataModel;
			}
			
            $pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$searchProductResponseDataModel->pagination = $paginationDataModel;
			}
		}
		return $searchProductResponseDataModel;
	}

}