<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\BrandDataModel;
use App\Models\Common\DataModels\OfferDataModel;


class UpdateOfferResponseDataModel extends ApiResponseDataModel
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
		$updateOfferResponseDataModel = new UpdateOfferResponseDataModel();
		if ($jsonData != null) {


            $offer = $jsonData->offer ?? null;
			if ($offer != null) {
				$offerDataModel = OfferDataModel::fromJson($offer);
				$updateOfferResponseDataModel->offer = $offerDataModel;
			}

     
		}
		return $updateOfferResponseDataModel;
	}
}