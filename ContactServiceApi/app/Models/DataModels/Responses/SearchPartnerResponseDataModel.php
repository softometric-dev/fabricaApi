<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationResponseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\PartnerDataModel;

class SearchPartnerResponseDataModel extends PaginationResponseDataModel
{

    public $partners;
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
		$searchPartnerResponseDataModel = new SearchPartnerResponseDataModel();
		if ($jsonData != null) {

            $partners = $jsonData->partners ?? null;
			if ($partners != null) {
				$searchPartnerResponseDataModel->partners = array();
				foreach ($partners as $partner) {
					$partnerDataModel = PartnerDataModel::fromJson($partner);
					$searchPartnerResponseDataModel->partners[] = $partnerDataModel;
				}
			}
		
			
            $pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$searchPartnerResponseDataModel->pagination = $paginationDataModel;
			}
		}
		return $searchPartnerResponseDataModel;
	}

}