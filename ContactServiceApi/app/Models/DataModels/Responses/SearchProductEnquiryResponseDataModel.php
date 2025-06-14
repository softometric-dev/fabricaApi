<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationResponseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\ProductEnquiryDataModel;

class SearchProductEnquiryResponseDataModel extends PaginationResponseDataModel
{

    public $productEnquiries;
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
		$searchProductEnquiryResponseDataModel = new SearchProductEnquiryResponseDataModel();
		if ($jsonData != null) {

            $productEnquiries = $jsonData->productEnquiries ?? null;
			if ($productEnquiries != null) {
				$searchProductEnquiryResponseDataModel->productEnquiries = array();
				foreach ($productEnquiries as $productEnquiry) {
					$productEnquiryDataModel = ProductEnquiryDataModel::fromJson($productEnquiry);
					$searchProductEnquiryResponseDataModel->productEnquiries[] = $productEnquiryDataModel;
				}
			}
		
			
            $pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$searchProductEnquiryResponseDataModel->pagination = $paginationDataModel;
			}
		}
		return $searchProductEnquiryResponseDataModel;
	}

}