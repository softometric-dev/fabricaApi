<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationResponseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\OfferDataModel;

class SearchOfferResponseDataModel extends PaginationResponseDataModel
{

    public $offers;
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
		$searchOfferResponseDataModel = new SearchOfferResponseDataModel();
		if ($jsonData != null) {

            $offers = $jsonData->offers ?? null;
			if ($offers != null) {
				$searchOfferResponseDataModel->offers = array();
				foreach ($offers as $offer) {
					$offerDataModel = OfferDataModel::fromJson($offer);
					$searchOfferResponseDataModel->offers[] = $offerDataModel;
				}
			}
		
			
            $pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$searchOfferResponseDataModel->pagination = $paginationDataModel;
			}
		}
		return $searchOfferResponseDataModel;
	}

}