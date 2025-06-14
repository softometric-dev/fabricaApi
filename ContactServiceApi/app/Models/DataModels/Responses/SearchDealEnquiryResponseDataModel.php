<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationResponseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\DealEnquiryDataModel;

class SearchDealEnquiryResponseDataModel extends PaginationResponseDataModel
{

    public $dealEnquiries;
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
		$searchDealEnquiryResponseDataModel = new SearchDealEnquiryResponseDataModel();
		if ($jsonData != null) {

            $dealEnquiries = $jsonData->dealEnquiries ?? null;
			if ($dealEnquiries != null) {
				$searchDealEnquiryResponseDataModel->dealEnquiries = array();
				foreach ($dealEnquiries as $dealEnquiry) {
					$dealEnquiryDataModel = DealEnquiryDataModel::fromJson($dealEnquiry);
					$searchDealEnquiryResponseDataModel->dealEnquiries[] = $dealEnquiryDataModel;
				}
			}
		
			
            $pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$searchDealEnquiryResponseDataModel->pagination = $paginationDataModel;
			}
		}
		return $searchDealEnquiryResponseDataModel;
	}

}