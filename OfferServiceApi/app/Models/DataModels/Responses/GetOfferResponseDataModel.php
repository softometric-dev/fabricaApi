<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\OfferDataModel;


class GetOfferResponseDataModel extends ApiResponseDataModel
{

    public $offer;
  
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
		$getOfferResponseDataModel = new GetOfferResponseDataModel();
		if ($jsonData != null) {

            $offer = isset($jsonData->offer) ? $jsonData->offer : null;
			if ($offer != null) {
				$offerDataModel = OfferDataModel::fromJson($offer);
				$getOfferResponseDataModel->offer = $offerDataModel;
			}


		}
		return $getOfferResponseDataModel;
	}


}